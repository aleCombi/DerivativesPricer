| **Test** | **Coverage** |
|:--------:|:------------:|
| [![Test Passing](https://github.com/aleCombi/DerivativesPricer/actions/workflows/ci.yml/badge.svg?event=push)](https://github.com/aleCombi/DerivativesPricer/actions) | [![Coverage Status](https://coveralls.io/repos/github/aleCombi/juliaExperiment/badge.svg?branch=master&cache-control=no-cache)](https://coveralls.io/github/aleCombi/juliaExperiment?branch=master) |

This library aims at pricing linear interest rates (IR) derivatives using a multi-curve framework.

# Features

  1. Daycount conventions,
  2. Schedules generation,
  3. Discount factors and forward rates calculations,
  4. Representation of fixed and floating rate swap legs,
  5. Rate curves based on a flat rate or an interpolation,
  6. Pricing of fixed and floating rate swap legs using rate curves.

The library has Symbolics.jl as a dependency with the purpose of running calculations symbolically for debugging or validation purposes.

# Roadmap

  1. Support Rate Curves interpolation in the space of rates rather than discount factors directly, based on a selected RateType.
  2. Develop a calibration routine for a single curve.
  3. Setup for MultiCurve pricing in a single currency.
  4. Proper testing and benchmarking with Quantlib.py. (See Issue [#2](#2))
  5. Setup Documenter.jl (See Issue [#1](#1))