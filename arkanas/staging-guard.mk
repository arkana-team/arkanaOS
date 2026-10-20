ifneq ($(origin STAGING_PATH),undefined)
$(error refusing STAGING_PATH override; Glibc and ldconfig must use the local ./staging root)
endif
