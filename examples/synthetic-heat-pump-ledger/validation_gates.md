# Synthetic Heat Pump Validation Gates

> Synthetic reduced workflow artifact. Numeric values are placeholders and are not certified design data, operating limits, or validated machine performance.

Before calling a heat-pump model complete, check:

- working fluid and property package are declared;
- evaporator and condenser heat duties close on both refrigerant and secondary-fluid sides;
- compressor pressure rise, power, and discharge temperature are physically plausible;
- expansion valve pressure drop and outlet state are finite;
- no heat exchanger has unexplained temperature crossing;
- dynamic wall, compressor, or controller states initialize near the intended operating point;
- COP is reported only after compressor power, auxiliaries, and heat duties are consistently defined.
