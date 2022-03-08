# Overview

A robot file that is being used as a sub-moduel in a larger robot project.

# Description

This robot has functionality to read a case from Salesforce, identify specific related data elemetns, and uplod Case Notes (FeedItem) back to the case in question. This leverages the [RPA.Salesforce](https://robocorp.com/docs/libraries/rpa-framework/rpa-salesforce) library from [Robocorp](https://robocorp.com/) and uses SOQL and the Salesforce API to interct with the Lightning version.