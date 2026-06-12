# Component-level dynamic contracts

Model level: componentized exploratory dynamic model.

The first component-level pass preserves the equations already checked in
the V0 dynamic plant. It does not add cooling, variable gas properties,
surge control, generator electromagnetic dynamics, rectifier dynamics, or
DC-bus energy storage.

## State Vector

| State | Unit | Source | Dynamic equation |
| --- | --- | --- | --- |
| `omega_GG_radps` | rad/s | design point | gas-generator rotor power balance |
| `omega_PT_radps` | rad/s | design point | power-turbine rotor power balance |
| `P3_Pa` | Pa | design point | combustor outlet volume mass balance |
| `P4_Pa` | Pa | design point | inter-turbine volume mass balance |
| `T3_K` | K | design point | first-order combustor thermal state |
| `Wf_act_kgps` | kg/s | design point | first-order fuel actuator |

## Compressor

| Field | Contract |
| --- | --- |
| Inputs | `omega_GG_radps`, `P3_Pa` |
| Outputs | `P2_Pa`, `T2_K`, `W_air_kgps`, `P_comp_W`, `pi_c`, `map_valid` |
| State variables | none |
| Map | synthetic public pressure-ratio/relative-speed map, scaled to design |
| Equation source | V0 `evaluate_gt_dynamics` and generic compressor template |
| Residual check | rated map flow equals design air flow |

## Combustor

| Field | Contract |
| --- | --- |
| Inputs | compressor `W_air_kgps`, compressor `T2_K`, state `T3_K`, state `Wf_act_kgps` |
| Outputs | `W_gas_kgps`, `T3_eq_K`, `fuel_air_ratio` |
| State variables | `T3_K` is integrated outside the component |
| Equation source | constant-heat-capacity energy balance from V0 |
| Residual check | rated `T3_eq_K - T3_K` equals zero |

## Gas-generator Turbine

| Field | Contract |
| --- | --- |
| Inputs | `P3_Pa`, `P4_Pa`, `T3_K`, combustor `W_gas_kgps` |
| Outputs | `W_TG_kgps`, `T4_K`, `P_TG_shaft_W`, `PR_TG`, `map_valid` |
| State variables | none |
| Map | Stodola/Flugel flow calibrated at design |
| Equation source | V0 dynamic plant and turbine template |
| Residual check | rated turbine flow equals combustor gas flow and shaft power equals compressor power |

## Power Turbine

| Field | Contract |
| --- | --- |
| Inputs | `P4_Pa`, gas-generator turbine `T4_K` |
| Outputs | `W_PT_kgps`, `T5_K`, `P_PT_shaft_W`, `PR_PT`, `map_valid` |
| State variables | none |
| Map | Stodola/Flugel flow calibrated at design |
| Equation source | V0 dynamic plant and turbine template |
| Residual check | rated turbine flow equals upstream turbine flow and shaft power equals load |

## Volumes

| Field | Contract |
| --- | --- |
| P3 inputs | combustor gas flow in, gas-generator turbine flow out, `T3_K` |
| P4 inputs | gas-generator turbine flow in, power turbine flow out, `T4_K` |
| Outputs | `dP3_Paps`, `dP4_Paps` |
| State variables | `P3_Pa`, `P4_Pa` |
| Equation source | `dP/dt = R*T*(G_in - G_out)/V` |
| Residual check | rated pressure derivatives equal zero |

## Rotors

| Field | Contract |
| --- | --- |
| GG inputs | turbine shaft power, compressor power, `omega_GG_radps` |
| PT inputs | power turbine shaft power, load shaft power, `omega_PT_radps` |
| Outputs | `domega_GG_radps2`, `domega_PT_radps2` |
| State variables | `omega_GG_radps`, `omega_PT_radps` |
| Equation source | `domega/dt = (P_in - P_out)/(J*omega)` |
| Residual check | rated rotor accelerations equal zero |

## Load And Fuel

| Field | Contract |
| --- | --- |
| Load inputs | `omega_PT_radps`, DC electrical load power |
| Load outputs | shaft load power, equivalent load torque |
| Fuel inputs | fuel command, actual fuel flow |
| Fuel outputs | `dWf_act_kgps2` |
| State variables | `Wf_act_kgps` |
| Residual check | rated fuel actuator derivative equals zero |

## Known Open Items

- Compressor efficiency uses a constant fallback in this public synthetic
  example.
- Turbine characteristic data have not yet replaced the Stodola/Flugel
  model.
- `T3_design_K = 1440 K` is a design point, not an absolute protection
  boundary. Continuous and transient temperature limits remain unresolved.
- Generator, rectifier, and DC-bus dynamics are outside the current model
  boundary.
