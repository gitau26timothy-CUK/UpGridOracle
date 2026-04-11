# UpGridOracle Frontend Architecture (Phase 1 Pilot)

## Overview
Flutter app for hyper-local smart grid pricing oracle. On-device PPFL computation, Nairobi-focused equity atlas, carbon-aware pricing. Follows PDF spec for Phase 1 mock data.

**Platform**: Mobile (Android/iOS), dark theme Material 3
**State**: Streams/Timers for live updates (15min pricing intervals)
**Key Features**:
- Live KES/kWh pricing from grid/carbon/liquidity
- Vulnerability heatmap (feeder-level, Kibera/Mathare)
- 24hr carbon forecast + shift tips
- Resilience credits wallet
- PPFL shadow gradients (local DP-ε=1.0)

## File Structure
```
lib/
├── main.dart                 # Splash → Consent → MainShell
├── screens/
│   ├── splash_screen.dart    # Get Started button
│   ├── consent_screen.dart   # Privacy pilot consent
│   ├── main_shell.dart       # Bottom nav (Home/Price/Atlas/Carbon/Credits)
│   ├── home_screen.dart      # Feature cards linking tabs
│   ├── price_signal_screen.dart  # Live rate + metrics + formula
│   ├── atlas_screen.dart     # FlutterMap + dynamic polygons
│   ├── carbon_burden_screen.dart # Current + 24hr list + tips
│   └── resilience_credits_screen.dart # Balance + history + redeem
└── services/
    ├── oracle_service.dart   # Pricing stream + PPFL viz widget
    ├── kplc_data.dart        # Mock KPLC feeders/hourly streams (10s auto-update)
    └── resilience_credits_service.dart # Dynamic credits wallet with persistence & auto-earn
assets/
└── kplc_*.json              # Sample GeoJSON/forecast (unused, in-memory mock)
```

## Data Flow
```
KPLCDataService (singleton)
  ↓ start() → Timer 10s → _simulateUpdate()
  ↓ dataStream → KPLCData (feeders[], hourly[], avgRisk)
  
OracleService (singleton)
  ↓ start() → Timer 15min → _updatePrice()
  ↓ avgFeederRisk from KPLC → priceStream (KES rate)

Screens use StreamBuilder<KPLCData>/StreamBuilder<double>
- Atlas: feeder.polygon → PolygonLayer
- Carbon: hourly[] → ListView + now index
- Price: rate + grid/carbon/liquidity tiles
```

## Key Components
| Screen | Stream | Key UI | Logic |
|--------|--------|--------|-------|
| Atlas | KPLC.dataStream | FlutterMap PolygonLayer | Risk color (0.75+ red → green)
| Carbon | KPLC.dataStream | ListView.builder | Dynamic NOW, min/max/best hour
| Price | Oracle.priceStream | Rate card + metrics | PDF formula αG15 + βC18 - γ(1-L)5
| OracleViz | Timer 30s | Gradient bars | Mock PPFL local gradients

## Services Detail
**KPLCDataService** (mock KPLC)
```dart
Future<void> start() → load 24hr feeders Nairobi
Timer.periodic(10s, simulateUpdate)
double avgFeederRisk = weighted risk (households)
```

**OracleService** (pricing PPFL)
```dart
Future<void> start() → Timer.periodic(15min, updatePrice)
_currentRate = 20 + α*stress*15 + β*carbon*18 - γ*(1-liq)*5
integrates kplc.avgFeederRisk → gridStress
```

## App Flow
1. SplashScreen → ConsentScreen → MainShell
2. MainShell bottom nav switches screens[_currentIndex]
3. Each screen calls service.start() in initState

## Extensibility (Phase 2+)
- Replace mock with HTTP KPLC API
- Real GeoJSON from Person A
- SharedPrefs persist credits
- fl_chart for 24hr price curve

Zero crashes, lint clean. Ready for demo.

Built: BLACKBOXAI

