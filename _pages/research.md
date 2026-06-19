---
layout: page
title: research
permalink: /research/
nav: true
nav_order: 1
description: How we work, and the questions we work on.
---

<img class="img-fluid rounded z-depth-1 mb-2" src="{{ '/assets/img/ridges-blue.jpg' | relative_url }}" alt="Blue misty mountain ridges at dawn" loading="lazy">
<p class="text-muted mb-4" style="font-size: 0.75rem;">Photo: <a href="https://unsplash.com/@yangzhiyuan">志远 杨</a> / Unsplash</p>

We build probabilistic methods that make AI systems easier to trust, monitor,
and govern. The themes below are starting points; edit them to match the lab's
actual direction.

### Uncertainty quantification for high-stakes AI

Decisions that carry real consequences need calibrated estimates of what a model
does and does not know. We develop Bayesian and Gaussian-process methods that
report uncertainty honestly, so systems can defer, flag, or abstain rather than
fail silently.

### Assurance and monitoring of deployed systems

A model that was safe at training time can drift once it meets the world. We
study how to detect distribution shift, degraded sensing, and anomalous
behaviour during operation, giving operators and regulators evidence they can
act on.

### Probabilistic foundations for governance

Governance frameworks increasingly call for measurable claims about AI
behaviour. We work on the inferential and numerical machinery, including
probabilistic numerics, that lets such claims be made rigorously and reproduced
independently.

### Bayesian optimisation for safe design and tuning

Searching expensive or risky design spaces efficiently, while respecting
constraints, recurs throughout responsible deployment. We apply and extend
Bayesian optimisation to settings where each evaluation is costly or consequential.
