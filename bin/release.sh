#!/bin/bash

bundle install && \
    git commit -m "release" && \
    git push origin main && \
    gem build explicit.gemspec --output explicit.gem && \
    gem push explicit.gem && \
    rm explicit.gem