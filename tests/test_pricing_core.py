from types import SimpleNamespace

from app.core.pricing import (
    apply_epra_adjustments,
    calculate_complete_pricing,
    calculate_tiered_pricing,
)


def test_calculate_tiered_pricing_splits_consumption():
    tiers = [
        SimpleNamespace(tier_name="T1", min_consumption=0, max_consumption=100, base_rate_kes=10.0),
        SimpleNamespace(tier_name="T2", min_consumption=100, max_consumption=200, base_rate_kes=20.0),
    ]

    total_base, breakdowns = calculate_tiered_pricing(150, tiers)

    assert total_base == 2000.0
    assert len(breakdowns) == 2
    assert breakdowns[0].tier_name == "T1"
    assert breakdowns[0].tier_consumption == 100
    assert breakdowns[1].tier_name == "T2"
    assert breakdowns[1].tier_consumption == 50


def test_apply_epra_adjustments_rounds_totals():
    total, adjustments = apply_epra_adjustments(100.0, epra_alpha=0.1, epra_beta=0.2, epra_gamma=0.3)

    assert total == 160.0
    assert adjustments["alpha"] == 10.0
    assert adjustments["beta"] == 20.0
    assert adjustments["gamma"] == 30.0
    assert adjustments["total_adjustment"] == 60.0


def test_calculate_complete_pricing_builds_response():
    tiers = [
        SimpleNamespace(tier_name="T1", min_consumption=0, max_consumption=50, base_rate_kes=5.0),
        SimpleNamespace(tier_name="T2", min_consumption=50, max_consumption=100, base_rate_kes=10.0),
    ]

    response = calculate_complete_pricing(
        customer_id="cust-123",
        consumption_kwh=75.0,
        category="residential",
        billing_period="2026-03",
        rate_tiers=tiers,
        epra_alpha=0.1,
        epra_beta=0.1,
        epra_gamma=0.1,
    )

    assert response.base_amount_kes == 500.0
    assert response.total_amount_kes == 650.0
    assert len(response.tiers_used) == 2
