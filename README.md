# Hedgehog.jl

<table>
  <tr>
    <td><strong>Test</strong></td>
    <td><a href="https://github.com/aleCombi/DerivativesPricer/actions">
      <img src="https://github.com/aleCombi/DerivativesPricer/actions/workflows/ci.yml/badge.svg?event=push" alt="Test Passing"></a>
    </td>
  </tr>
  <tr>
    <td><strong>Coverage</strong></td>
    <td><a href='https://coveralls.io/github/aleCombi/DerivativesPricer?branch=master'><img src='https://coveralls.io/repos/github/aleCombi/DerivativesPricer/badge.svg?branch=master&service=github' alt='Coverage Status' /></a>
    </td>
  </tr>
  <tr>
    <td><strong>License</strong></td>
    <td><a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
    </td>
  </tr>
    <tr>
    <td><strong>Code Quality</strong></td>
    <td><a href="https://github.com/JuliaTesting/Aqua.jl">
      <img src="https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg" alt="Aqua QA"></a>
    </td>
  </tr>
</table>

This library aims at pricing linear interest rates (IR) derivatives using a multi-curve framework.

## Features

  1. Daycount conventions,
  2. Schedules generation, with business days adjustments (e.g.: Modified Following) and roll conventions (e.g.: End-Of-Month),
  3. Discount factors and forward rates calculations,
  4. Representation of fixed and floating rate swap legs,
  5. Rate curves based on a flat rate or an interpolation,
  6. Pricing of fixed and floating rate swap legs using rate curves.

The library has Symbolics.jl as a dependency with the purpose of running calculations symbolically for debugging or validation purposes.

## Roadmap

- Decouple modules low level functionality for better unit testing, write orchestrators separately.
- Support Rate Curves interpolation in the space of rates rather than discount factors directly, based on a selected RateType (COMPLETE).
- Develop a calibration routine for a single curve.
- Setup for MultiCurve pricing in a single currency.
- Proper testing and benchmarking with Quantlib.py. (See Issue [#2](#2))
