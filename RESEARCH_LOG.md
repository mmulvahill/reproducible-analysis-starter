Append-only. Newest entries at the bottom. What happened, what we learned,
and what it changed. Short is fine.

**2026-10-11** Received data (235 patients, 19 variables) from the
`medicaldata` package. Checksum recorded. Codebook says the data are
cleaned; the pipeline validates ranges and codes anyway.

**2026-10-11** Patients 113 and 123 are missing every post-operative
outcome, nothing else. Complete-case for outcomes (D-006).

**2026-10-11** Simulation check: `fit_repeated()` and `fit_marginal()` both
recover a planted treatment effect. Trusting them on the trial data.

**2026-10-11** First mixed-model fit gave a conditional OR around 0.13,
against about 0.4 at 30 minutes alone. Not a bug: the patient random
intercept SD is about 2.7 on the log-odds scale, so conditional and marginal
ORs diverge strongly. Added the GEE as the population estimand and kept the
mixed model, labeled (D-003, D-004).

**2026-10-11** Broke the code on purpose to test the tests. Replacing the
mixed model with a plain logistic regression that ignores patients passed
every test: the recovery test only checked the treatment effect, loosely.
Strengthened it to recover the patient SD too, and to require a clear gap
between conditional and marginal estimates. The same swap now fails two tests.
