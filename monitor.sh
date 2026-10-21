#!/bin/bash

# Count total failed
FAILED_TOTAL=$(cat payments.log | grep -c FAILED)
echo "Total failed: $FAILED_TOTAL"

# Count alice failures
ALICE_FAILED=$(cat payments.log | grep alice | grep -c FAILED)
echo "Alice failed: $ALICE_FAILED"

# Check critical threshold
if [ $FAILED_TOTAL -gt 2 ]; then
  echo "CRITICAL: High failure rate - $FAILED_TOTAL failures detected at $(date)" >> alerts.log
fi

# Check fraud rule
if [ $ALICE_FAILED -ge 2 ]; then
  echo "FRAUD_CHECK: user alice has $ALICE_FAILED failures - review at $(date)" >> alerts.log
fi

cat alerts.log
