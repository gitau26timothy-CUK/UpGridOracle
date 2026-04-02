"""
Pricing calculation engine for energy consumption with multi-tier support.
EPRA (Energy and Petroleum Regulatory Authority) adjustments applied.
"""
from app.schemas import PricingBreakdown, PricingResponse
from typing import List


def calculate_tiered_pricing(
    consumption_kwh: float,
    rate_tiers: List,  # List of RateTier models
) -> tuple[float, List[PricingBreakdown]]:
    """
    Calculate cost using tiered pricing.
    
    Args:
        consumption_kwh: Total consumption in kWh
        rate_tiers: Sorted list of RateTier objects for the category
    
    Returns:
        (total_base_cost_kes, list of breakdowns per tier)
    """
    remaining_consumption = consumption_kwh
    total_base_cost = 0.0
    tiers_used = []

    # Sort tiers by min_consumption to ensure correct ordering
    sorted_tiers = sorted(rate_tiers, key=lambda t: t.min_consumption)

    for tier in sorted_tiers:
        if remaining_consumption <= 0:
            break

        # How much consumption falls into this tier?
        tier_consumption = min(remaining_consumption, tier.max_consumption - tier.min_consumption)
        
        if tier_consumption <= 0:
            continue

        tier_cost = tier_consumption * tier.base_rate_kes
        total_base_cost += tier_cost

        tiers_used.append(
            PricingBreakdown(
                consumption_kwh=tier_consumption,
                tier_name=tier.tier_name,
                base_rate_kes=tier.base_rate_kes,
                tier_consumption=tier_consumption,
                tier_cost=tier_cost,
                epra_adjustment=0.0,  # Will be calculated later
            )
        )

        remaining_consumption -= tier_consumption

    return total_base_cost, tiers_used


def apply_epra_adjustments(
    base_amount_kes: float,
    epra_alpha: float = 0.4,
    epra_beta: float = 0.35,
    epra_gamma: float = 0.25,
) -> tuple[float, dict]:
    """
    Apply EPRA adjustment factors to base cost.
    
    EPRA factors represent regulatory adjustments:
    - alpha: Primary adjustment (typically largest)
    - beta: Secondary adjustment
    - gamma: Tertiary adjustment
    
    Args:
        base_amount_kes: Base cost before adjustments
        epra_alpha, epra_beta, epra_gamma: Adjustment factors (as decimals)
    
    Returns:
        (adjusted_total_kes, adjustment_details)
    """
    # Calculate individual adjustments
    alpha_adjustment = base_amount_kes * epra_alpha
    beta_adjustment = base_amount_kes * epra_beta
    gamma_adjustment = base_amount_kes * epra_gamma

    total_adjustment = alpha_adjustment + beta_adjustment + gamma_adjustment
    total_amount = base_amount_kes + total_adjustment

    adjustments = {
        "alpha": round(alpha_adjustment, 2),
        "beta": round(beta_adjustment, 2),
        "gamma": round(gamma_adjustment, 2),
        "total_adjustment": round(total_adjustment, 2),
    }

    return round(total_amount, 2), adjustments


def calculate_complete_pricing(
    customer_id: str,
    consumption_kwh: float,
    category: str,
    billing_period: str,
    rate_tiers: List,  # All rate tiers for the customer's category
    epra_alpha: float = 0.4,
    epra_beta: float = 0.35,
    epra_gamma: float = 0.25,
) -> PricingResponse:
    """
    Complete end-to-end pricing calculation.
    
    Args:
        customer_id: Customer identifier
        consumption_kwh: Total kWh consumed
        category: Customer category (residential, commercial, etc.)
        billing_period: Billing period (e.g., "2026-03")
        rate_tiers: List of applicable RateTier objects
        epra_alpha, epra_beta, epra_gamma: EPRA adjustment factors
    
    Returns:
        PricingResponse with complete breakdown
    """
    # Step 1: Calculate tiered pricing
    base_amount, tiers_used = calculate_tiered_pricing(consumption_kwh, rate_tiers)

    # Step 2: Apply EPRA adjustments
    total_amount, adjustments = apply_epra_adjustments(
        base_amount, epra_alpha, epra_beta, epra_gamma
    )

    # Step 3: Return complete response
    return PricingResponse(
        customer_id=customer_id,
        consumption_kwh=consumption_kwh,
        category=category,
        billing_period=billing_period,
        base_amount_kes=base_amount,
        epra_adjustments=adjustments,
        total_amount_kes=total_amount,
        tiers_used=tiers_used,
    )
