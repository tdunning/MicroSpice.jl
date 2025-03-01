```@meta
CurrentModule = MicroSpice
```

# MicroSpice

[MicroSpice](https://github.com/tdunning/MicroSpice.jl) is a very
simple circuit simulator that simulates an electronic circuit composed
a variety of passive components. This circuit can be constructed using
a subset of standard Spice netlist syntax.

As an example, here is a simple RLC circuit with `in` as input and `out` as
output

```
L1 in  out 100nH
R1 out gnd  50Ω
C1 out gnd 100nF
```

Currently the only supported components are resistors (R), inductors (L)
and capacitors (C). Component values can be specified using standard SI
prefixes such as `k` (kilo = 1e3), `M` (Mega=1e6), `G`(giga=1e9), `m`
(milli=1e-3), `μ` (micro=1e-6), `n` (nano=1e-9), or `p` (pico=1e-12). In
addition, the non-standard forms `u` (micro=1e-6) and `meg` (Mega=1e6) are
also allowed for Spice compatibility.

Units including H (Henry), F (Farad) and Ω (ohm) are allowed, but are
optional.  If you do use a unit, the unit must match the type of
component. Thus, you can specify the value of a resistor as `50Ω` but
claiming that is the value of a capacitor would be an error.

Component values can also be a reference to a parameter. For instance,
we could modify the circuit above to parameterize the value of the
inductor and capacitor:

```
L1 in  out $L
R1 out gnd  50Ω
C1 out gnd $C
```
To simulate this circuit, we have to provide these values. More on how
to use this [later](#Circuit-parameters)
## Running a Simulation

A `Netlist` describes an abstract circuit. To simulate that circuit,
the circuit is turned into a matrix equation consisting of complex
admittances that relate the voltages and currents in the circuit. In
this conversion, the voltages for any subset of nodes can be forced to
a particular value and currents can be injected into any nodes that
are not set to a voltage.  The result of the voltages and all of the
node-to-node currents are then computed.

In normal practice, the internals of this conversion are hidden from
view.  All you need to do is provide a `Netlist` and circuit
parameters and you get a simulation function that takes a frequency, a
vector of voltages and returns a vector of output voltages. You can
call that simulation function repeatedly for different frequencies or
different inputs.

Taking the circuit given above, if we take node `in` as the input,
node `out` as the output and `gnd` as the ground reference, we can
simulate the voltage transfer function for this circuit with this
code:

```jldoctest; filter = r"(\d*)\.(\d{9})\d+" => s"\1.\2***"
using MicroSpice
nl = MicroSpice.Netlist("L1 in  out 100nH\nR1 out gnd 50Ω\nC1 out gnd 100nF\n",
                                     [], [:in, :gnd], ["out"])
s = MicroSpice.solve(nl)
decibel(x) = 20 * log10(abs(x))
[decibel(only(s(f, [1, 0], []))) for f in [1.4e6, 1.5e6, 1.62e6, 1.8e6]]
# output
4-element Vector{Float64}:
 12.883077832402897
 18.914298710446417
 27.65586909592151
 11.05634871505561
```
## Circuit parameters

If you have component values that are parameter references (such as
`$L` in the example above), the values of the parameters must be
supplied when you solve the circuit. Even before that, though, when
you construct the `Netlist`, you need to provide the names of the
parameters that you will be providing later as a list. This list also
specifies the order in which you will provide the values later.

Here is an example with the circuit from before but with parameters
for the inductor and capacitor. Note the use of a raw string for the
circuit definition to avoid needing to quote the `$` before the
parameter names.

```jldoctest; filter = r"(\d*)\.(\d{9})\d+" => s"\1.\2***"
using MicroSpice
nl = MicroSpice.Netlist(raw"""
L1 in  out $L
R1 out gnd 50Ω
C1 out gnd $C
""", ["L", "C"], [:in, :gnd], ["out"])
decibel(x) = 20 * log10(abs(x))
[ 
decibel(only(MicroSpice.solve(nl)(f, [1, 0], params)))
for f in  [1.0e6, 1.2e6, 1.4e6, 1.62e6, 1.8e6, 2.0e6],
params in  [[100e-9, 100e-9], [200e-9, 50e-9], [120e-9, 100e-9]]
]
# output
6×3 Matrix{Float64}:
  4.35992   4.35431   5.57245
  7.29487   7.279     9.94251
 12.8831   12.8055   22.5545
 27.6559   25.2887   12.2341
 11.0563   10.9722    5.42304
  4.73621   4.71178   0.958959
```
In this example, the `Netlist` is defined and all parameters, inputs
and outputs are bound to symbol names. The circuit parameters are
passed to the `solve` function to get a simulation function and that
function is given the frequency of interest and the circuit inputs to
get the resulting output voltages.

```@index
```

```@autodocs
Modules = [MicroSpice]
```
