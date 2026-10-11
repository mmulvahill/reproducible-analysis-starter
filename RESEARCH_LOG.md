Append-only. Newest entries at the bottom. What happened, what we learned,
and what it changed. Short is fine. This is a hand-written log, so its
numbers are typed; the report chapters compute theirs.

**2026-10-10** Received data (235 patients, 19 variables) from the
`medicaldata` package. Checksum recorded. The codebook says the study
enrolled 236, so one enrolled patient is not in the public file; open
question for the client. The codebook also says the data are cleaned; the
pipeline validates ranges and codes anyway.

**2026-10-10** Patients 113 (licorice) and 123 (sugar) are missing every
post-operative outcome, nothing else. Complete-case for outcomes with
best/worst-case bounds (D-006).

**2026-10-10** Simulation check: `fit_repeated()` and `fit_marginal()` both
recover planted effects, including the marginal OR computed by integrating
out the patient effect. Trusting them on the trial data.

**2026-10-10** Broke the code on purpose to test the tests. Replacing the
mixed model with a plain logistic regression that ignores patients passed
every test: the recovery test only checked the treatment effect, loosely.
Strengthened it to recover the patient SD too, and to require a clear gap
between conditional and marginal estimates. The same swap now fails two tests.

**2026-10-10** Planned models fitted. The mixed model's conditional OR
(about 0.14) is far from the GEE's marginal OR (about 0.34) because the
patient random-intercept SD is about 2.75 on the log-odds scale. Expected
direction, larger gap than anticipated; reported both as planned (D-004).

**2026-10-10** Independent review (fresh session) flagged that the Laplace
approximation can be biased here; switched the mixed model to adaptive
quadrature (OR moved from about 0.13 to 0.14). It also flagged that the
client's "does it last?" question was unanswered; added the time-specific
GEE planned in D-003, and a test that the GEE recovers the true marginal OR.
