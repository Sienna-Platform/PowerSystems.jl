# Glossary and Acronyms

[A](@ref) | [D](@ref) | [E](@ref) | [F](@ref) | [H](@ref) | [I](@ref) | [O](@ref) | [P](@ref) | [R](@ref) |
[S](@ref) | [V](@ref) | [W](@ref) | [Z](@ref)

### A

  - *AC*: Alternating current

  - *ACE*: Area control error

  - *AGC*: Automatic generation control

  - *AVR*: Automatic Voltage Regulator

### D

  - *DC*: Direct current

  - *DERA1*:

  - *Dynamic*: Refers to data and simulations for power system transient simulations using differential
    equations. Common examples include signal stability analysis to verify the power system will
    maintain stability in the few seconds following an unexpected fault or generator trip. For contrast,
    see the definition for [Static](@ref S) data.

### E

  - *EMF*: Electromotive force
  - *ESAC*: IEEE Type AC Excitation System model
  - *ESDC*: IEEE Type DC Excitation System model
  - *EXAC*: IEEE Type AC Excitation System (modified) model
  - *EXPIC*: Proportional/Integral Excitation System from PSS/E
  - *EXST*: IEEE Type ST (Static) Excitation System model
  - *EX4VSA*: IEEE Excitation System for Voltage Security Assessment with Over-Excitation Limits.

### F

  - *Forecast*: Predicted values of a time-varying quantity that commonly features
    a look-ahead and can have multiple data values representing each time period.
    This data is used in simulation with receding horizons or data generated from
    forecasting algorithms. See the article on [`Time Series Data`](@ref ts_data).

  - *Forecast window*: Represents the forecasted value starting at a particular initial time.
    See the article on [`Time Series Data`](@ref ts_data).

### H

  - *Horizon*: Is the duration of all time steps in one forecast. As of PowerSystems.jl
    version 4.0, all horizons in `PowerSystems.jl` are represented as a `Dates.Period`.
    For instance, many Day-ahead markets will have an hourly-[resolution](@ref R) forecast
    for the next day, which would have a horizon of `Dates.Hour(24)` or `Dates.Day(1)`. If the
    forecast included the next day plus a 24-hour lookahead window, the horizon would be
    `Dates.Hour(48)` or `Dates.Day(2)`. See the article on [`Time Series Data`](@ref ts_data).

  - *HVDC*: High-voltage DC

### I

  - *IEEET*: IEEE Type I Excitation System.

  - *Injector* or *Injection*: Injectors refer to models that represent how a generator or storage
    device *injects* power or current into the power system. Loads are negative injectors. In
    `PowerSystems.jl`, some components can accept data for both [`StaticInjection`](@ref) and
    [`DynamicInjection`](@ref) models for both [static](@ref S) and [dynamic](@ref D) modeling.

  - *Interval*: The period of time between forecast initial times. In `PowerSystems.jl` all
    intervals are represented using `Dates.Period` types. For instance, in a Day-Ahead market
    simulation, the interval is usually `Hour(24)`.

  - *Initial time*: The first time-stamp in a forecast window. See the article on
    [`Time Series Data`](@ref ts_data).

  - *IPC*: Interconnecting power converter

### L

  - *LCC*: Line Commutated Converter HVDC line

### O

  - *OEL*: Over Excitation Limiter

### P

  - *PLL*: Phase-locked loop

  - *PSS*: Power System Stabilizer

  - *PSSE* or *PSS/E*: Siemens' PSS®E Power System Simulator for Engineering

  - *PPA*: Power purchase agreement

  - *PSI*: [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/)

  - *PSID*: [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/)

  - *PSLF*: GE Vernova's Positive Sequence Load Flow Software

  - *PSY*: `PowerSystems.jl` (this package)

  - *pu* or *p.u.*: Per-unit

### R

  - *REECB1*: Renewable Energy Electric Controller Type B1
  - *REPCA1*: REPCA1: Renewable Energy Power Controller Type A1
  - *Resolution*: The period of time between each discrete value in a time series. All resolutions
    are represented using `Dates.Period` types. For instance, a Day-ahead market data set usually
    has a resolution of `Hour(1)`, a Real-Time market data set usually has a resolution of `Minute(5)`.

### S

  - *SCRX*: Bus Fed or Solid Fed Static Exciter

  - *SEXS*: Simplified Excitation System model from PSS/E

  - *SIL*: Surge impedance loading

  - *States*: Correspond to the set of inputs, outputs or variables, that evolve dynamically in
    [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/),
    commonly via a differential-algebraic system of equations. In `PowerSystems.jl`, a component
    associated to a `DynamicInjector` (for example an AVR) specifies the set of states that specific
    component requires to be modeled accurately.

  - *Static*: Typically refers to steady state data or models where the power system
    and each of its components are assumed to be operating at a steady state equilibrium point. This
    includes both power flow data for a single time point simulation as well as quasi-static time
    series data and models, where the power system is at an equilibrium point at each time step.
    Static data can be used as the input to single time point power flow models and production
    cost models with, for example, 5-minute, 15-minute, or 1-hour [Resolution](@ref R).
    For contrast, see the definition for [Dynamic](@ref D) data.

  - *STAB*: Speed Sensitive Stabilizing PSS Model

### V

  - *VSCLine*: Voltage-Source Converter HVDC Line

  - *VSM*: Virtual Synchronous Machine

### W

  - *Window*: A forecast window is one forecast run that starts at one [initial time](@ref I)
    and extends through the forecast [horizon](@ref H). Typically, a forecast data set
    contains multiple forecast windows, with sequential initial times. For example, a
    year-long data set of day-ahead forecasts contains 365 forecast windows

### Z

  - *ZIP load*: A ZIP load model accounts for the voltage-dependency of a load and is primarily used
    for dynamics modeling. It includes three kinds of load: constant impedance (Z), constant current (I),
    and constant power (P), though many dynamics models just use the constant impedance model.
    [`StandardLoad`](@ref) and [`ExponentialLoad`](@ref) are both ZIP load models:
    [`StandardLoad`](@ref) breaks up the load into each of its three components, while
    [`ExponentialLoad`](@ref) expresses the load as an exponential equation.
