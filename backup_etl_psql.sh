#!/bin/bash

# STEPS
# 1. stop the etl
# 2. compress etl data directory to .zip file
# 3. dump database to .zip file
# 4. upload to S3 or some other cloud storage
# 5. delete .zip files
# 6. restart etl
# 7. profit
