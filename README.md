This library aims at writing demo functions to prepare for a more extensive derivative evaluation library.
Main ideas:
  1. Using symbolic calculus, storing symbolic expressions for products and the reevaluating them when need be.
  2. Start from linear derivatives.
  3. Write rate curves objects.
  4. Separate structures for payoffs (as in list of symbolic cash flows) and for evaluations (sums of discounted cash flows)
  5. In the demo the model should be single curve, without convexity adjustments.
  6. Next up we can add FX conversions.
  7. Benchmark for accuracy and performance against Quantlib.jl.
