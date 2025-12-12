# COPR build instructions for Fedpunk
# Build SRPM from spec file using standard rpmbuild

srpm:
	# Install required tools
	dnf install -y rpmdevtools wget rpm-build

	# Download the source tarball from GitHub
	spectool -g -R fedpunk.spec

	# Build the SRPM
	rpmbuild -bs fedpunk.spec \
		--define "_sourcedir $(shell pwd)" \
		--define "_srcrpmdir $(outdir)" \
		--define "_topdir $(outdir)"
