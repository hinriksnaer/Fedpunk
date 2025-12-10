# COPR build instructions for Fedpunk
# This file tells COPR how to build the source RPM

srpm:
	dnf install -y rpkg git
	git config --global --add safe.directory '*'
	rpkg srpm --outdir $(outdir)
