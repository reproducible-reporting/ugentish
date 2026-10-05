#!/usr/bin/env python3
from stepup.core.api import call, static

static("convert_colors.py", "matplotlib/matplotlibrc_template", "typst/")
call("./convert_colors.py", "plan")
