| **Test** | **Coverage** |
|:--------:|:------------:|
| [![Test Passing](https://github.com/aleCombi/DerivativesPricer/actions/workflows/ci.yml/badge.svg?event=push)](https://github.com/aleCombi/DerivativesPricer/actions) | [![Coverage Status](https://coveralls.io/repos/github/aleCombi/juliaExperiment/badge.svg?branch=master&cache-control=no-cache)](https://coveralls.io/github/aleCombi/juliaExperiment?branch=master) |

This library aims at pricing linear interest rates (IR) derivatives using a multi-curve framework.

# Features

  1. Daycount conventions,
  2. Schedules generation, with business days adjustments (e.g.: Modified Following) and roll conventions (e.g.: End-Of-Month),
  3. Discount factors and forward rates calculations,
  4. Representation of fixed and floating rate swap legs,
  5. Rate curves based on a flat rate or an interpolation,
  6. Pricing of fixed and floating rate swap legs using rate curves.

The library has Symbolics.jl as a dependency with the purpose of running calculations symbolically for debugging or validation purposes.

# Roadmap

- Decouple modules low level functionality for better unit testing, write orchestrators separately.
- Support Rate Curves interpolation in the space of rates rather than discount factors directly, based on a selected RateType.
- Develop a calibration routine for a single curve.
- Setup for MultiCurve pricing in a single currency.
- Proper testing and benchmarking with Quantlib.py. (See Issue [#2](#2))
- Setup Documenter.jl (See Issue [#1](#1))

