#!/bin/bash

bin/horizon --stellar-core-url postgresql://root:root@188.0.0.24:5432/horizon?sslmode=disable
bin/horizon --stellar-core-db-url postgresql://root:root@188.0.0.24:5432/stellarcore?sslmode=disable
bin/horizon --db-url http://188.0.0.22:11625
bin/horizon db migrate up
bin/horizon serve
