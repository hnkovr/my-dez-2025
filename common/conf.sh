#!/bin/bash
get_env_var() {
  grep "^$1=" .env | cut -d '=' -f2
}
