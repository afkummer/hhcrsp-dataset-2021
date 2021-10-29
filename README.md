# A new curated benchmark dataset for the home health care problem

This repository contains the new benchmark dataset for the home health care routing and scheduling problem, introduced by [Mankowska et al. (2014)](https://doi.org/10.1007/s10729-013-9243-1). These new instances were generated using a modified version of the [OVIG](https://github.com/afkummer/ovig) tool, introduced by [Sartori and Buriol (2020)](https://github.com/cssartori/ovig).

The directory [instances](instances) contains all the instances we generated, using the OpenAddresses database for Porto Alegre (Brazil). We also compute lower and upper bound for all the instances we generated, by solving a linear programming relaxation of such problem, and a genetic algorithm, respectively.

After these initial computation, we then select, per instance size:

- The top-10 instances with the largest optimality gap, computed as gap% = (UB-LB)/UB * 100.0
- Other 10 instances, selected at random

This way, each instance size comprises 20 distinct instances. We followed this methodology to select instances that are hard to current algorithms, and other instances at random so hopefully the dataset is somewhat future-proof.

Among all the instances, the 'final' dataset comprises the instances from [dataset.csv](dataset.csv). You can also generate your own dataset by modifying the [selectInstances.R](selectInstances.R) script.


