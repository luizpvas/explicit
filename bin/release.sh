#!/bin/bash

gem build explicit.gemspec --output explicit.gem && \
    bundle install && \
    gem push explicit.gem && \
    rm explicit.gem