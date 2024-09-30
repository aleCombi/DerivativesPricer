[![Coverage Status](https://coveralls.io/repos/github/aleCombi/juliaExperiment/badge.svg?branch=master&cache-control=no-cache)](https://coveralls.io/github/aleCombi/juliaExperiment?branch=master)
![example event parameter](https://github.com/github/docs/actions/workflows/master.yml/badge.svg?event=push)

This library aims at writing some derivatives pricers
Main ideas:
  1. Using symbolic calculus, storing symbolic expressions for products and the reevaluating them when need be.
  2. Start from linear derivatives.
  3. Write rate curves objects.
  4. Separate structures for payoffs (as in list of symbolic cash flows) and for evaluations (sums of discounted cash flows)
  5. In the demo the model should be single curve, without convexity adjustments.
  6. Next up we can add FX conversions.
  7. Benchmark for accuracy and performance against Quantlib.jl.
  8. Move this list into a number of Issues and give descriptive text here
