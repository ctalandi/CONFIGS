#!/bin/bash

set -xv 



ncks -d y,88,3146 EORCA12.L75-MJMgd16_y1989m12.5d_gridT.nc ORCA12.L75-MJMgd16_y1989m12.5d_gridT.nc
./convert_wrap_orca12_gridT ORCA12.L75-MJMgd16_y1989m12.5d_gridT.nc CREG12.L75-MJMgd16_y1989m12.5d_gridT.nc
