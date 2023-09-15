# The curent repository gathers information to perform tests using a passive tracer 
with either the ORCA2 or the eORCA025.L75 configuration. This work has been done 
during Anne GAYMARD M2 internship during 2023 summer time.

1 - ORCA2-OFF-LINE:<br> 
2 - ORCA2-MYTRC-OFF-LINE:<br>
3 - eORCA025.L75-OFF-LINE:<br>
  
---
## 1 - ORCA2-OFF-LINE: <br>
This configuration has been used as a training one to understand how to setup an off-line configuration. <br>
It relies on the NEMO reference configuration named ORCA2_OFF_TRC in which several passive tracers such as CFC, C14 and also the age are set. <br>
This experiment has been run on Datarmor and relies on the NEMO release 4.2.0 <br>

---
## 2 - ORCA2-MYTRC-OFF-LINE: <br>
This configuration is used to set up our own passive tracer. It is initialized at the surface on 3 sub-regions in the North Atlantic SPG, NAC STG respectively.<br>
It relies on the NEMO reference configuration named ORCA2_OFF_TRC. 
This experiment has been run on Datarmor and relies on the NEMO release 4.2.0 <br>

---
## 2 - eORCA025.L75-OFF-LINE:<br>
This configuration has been used to perform an experiment at a higher horizontal and vertical resolution to compare with results from an ARIANE Lagrangian simulation using the same input data from the IMHOTEP project.<br>
The NEMO release 4.0.6 has been used, and more precisely the same code version used to perform the eORCA025.L75-IMHOTEP.GAI simulation within the IMHOTEP project.<br>
The numerical experiment has been realised on the Jean-Zay computer (IDRIS) .<br> 
