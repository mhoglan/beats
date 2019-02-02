Changes to include PR 8488 which fixes Docker eventing
https://github.com/elastic/beats/pull/8488

Build setup:

* Have `golang` installed
* Update `$PATH` to include the `$GOPATH/bin`
  * `$GOPATH` defaults to `$HOME/go` when not defined;
* Have `mage` installed

```
brew install golang
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
go get -u -d github.com/magefile/mage
cd $GOPATH/src/github.com/magefile/mage
go run bootstrap.go
```

Get the `elastic/beats` source;  Needs to be in a proper `$GOPATH` setup.

Can get the source for beats with `go get`;  `-d` means download only.

```
git clone git@github.com:elastic/beats $GOPATH/src/github.com/elastic/beats
```

or

Can get the source with `git clone`

```
go get -u -d github.com/elastic/beats
```

Change to beats project


```
cd $GOPATH/src/github.com/elastic/beats
```

Generate patch from PR and apply to desired branch / tag (in this case `6.6.0`);  `e7f50bf0ad8d9976a309ee840b1ca3b751112e53` is the SHA from the fork point of the PR.  Create patch since that SHA.

```
git fetch git@github.com:brianjones/beats.git master:pr8488
git checkout pr8488
git format-patch --stdout e7f50bf0ad8d9976a309ee840b1ca3b751112e53 > pr8488.patch
git fetch --tags origin
git checkout -b v6.6.0-pr8488 tags/v6.6.0
git am pr8488.patch
```

Pushing patched branch to forked remote to keep track of

```
git remote add mhoglan git@github.com:mhoglan/beats
git push mhoglan v6.6.0-pr8488
```

Move into `filebeat` specifically to build it.  Perform a cross compile for `linux` with `amd64`

```
cd filebeat/
GOOS=linux GOARCH=amd64 make
```

Binary now exists.

```
❯ file filebeat
filebeat: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```

Need to create a new docker image with the patched binary.  Will replace the binary in the official image.   `filebeat-patch.Dockerfile` is present to provide this.

```
docker build -t docker.io/mhoglan/filebeat:6.6.0 -f filebeat-patch.Dockerfile .
```

Check the version of the binary in the new image

```
❯ docker run -it --rm docker.io/mhoglan/filebeat:6.6.0 version
filebeat version 6.6.0 (amd64), libbeat 6.6.0 [cc892dd57a7cbb803205b607220e1aa4294e90fd built 2019-02-02 18:29:38 +0000 UTC]
```

Push up to DockerHub to share

```
docker push docker.io/mhoglan/filebeat:6.6.0
```

---

[![Travis](https://travis-ci.org/elastic/beats.svg?branch=master)](https://travis-ci.org/elastic/beats)
[![GoReportCard](http://goreportcard.com/badge/elastic/beats)](http://goreportcard.com/report/elastic/beats)
[![codecov.io](https://codecov.io/github/elastic/beats/coverage.svg?branch=master)](https://codecov.io/github/elastic/beats?branch=master)

# Beats - The Lightweight Shippers of the Elastic Stack

The [Beats](https://www.elastic.co/products/beats) are lightweight data
shippers, written in Go, that you install on your servers to capture all sorts
of operational data (think of logs, metrics, or network packet data). The Beats
send the operational data to Elasticsearch, either directly or via Logstash, so
it can be visualized with Kibana.

By "lightweight", we mean that Beats have a small installation footprint, use
limited system resources, and have no runtime dependencies.

This repository contains
[libbeat](https://github.com/elastic/beats/tree/master/libbeat), our Go
framework for creating Beats, and all the officially supported Beats:

Beat  | Description
--- | ---
[Auditbeat](https://github.com/elastic/beats/tree/master/auditbeat) | Collect your Linux audit framework data and monitor the integrity of your files.
[Filebeat](https://github.com/elastic/beats/tree/master/filebeat) | Tails and ships log files
[Heartbeat](https://github.com/elastic/beats/tree/master/heartbeat) | Ping remote services for availability
[Metricbeat](https://github.com/elastic/beats/tree/master/metricbeat) | Fetches sets of metrics from the operating system and services
[Packetbeat](https://github.com/elastic/beats/tree/master/packetbeat) | Monitors the network and applications by sniffing packets
[Winlogbeat](https://github.com/elastic/beats/tree/master/winlogbeat) | Fetches and ships Windows Event logs

In addition to the above Beats, which are officially supported by
[Elastic](https://elastic.co), the community has created a set of other Beats
that make use of libbeat but live outside of this Github repository. We maintain
a list of community Beats
[here](https://www.elastic.co/guide/en/beats/libbeat/master/community-beats.html).

## Documentation and Getting Started

You can find the documentation and getting started guides for each of the Beats
on the [elastic.co site](https://www.elastic.co/guide/):

* [Beats platform](https://www.elastic.co/guide/en/beats/libbeat/current/index.html)
* [Auditbeat](https://www.elastic.co/guide/en/beats/auditbeat/current/index.html)
* [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
* [Heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/index.html)
* [Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html)
* [Packetbeat](https://www.elastic.co/guide/en/beats/packetbeat/current/index.html)
* [Winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/current/index.html)


## Getting Help

If you need help or hit an issue, please start by opening a topic on our
[discuss forums](https://discuss.elastic.co/c/beats). Please note that we
reserve GitHub tickets for confirmed bugs and enhancement requests.

## Downloads

You can download pre-compiled Beats binaries, as well as packages for the
supported platforms, from [this page](https://www.elastic.co/downloads/beats).

## Contributing

We'd love working with you! You can help make the Beats better in many ways:
report issues, help us reproduce issues, fix bugs, add functionality, or even
create your own Beat.

Please start by reading our [CONTRIBUTING](CONTRIBUTING.md) file.

If you are creating a new Beat, you don't need to submit the code to this
repository. You can simply start working in a new repository and make use of the
libbeat packages, by following our [developer
guide](https://www.elastic.co/guide/en/beats/libbeat/current/new-beat.html).
After you have a working prototype, open a pull request to add your Beat to the
list of [community
Beats](https://github.com/elastic/beats/blob/master/libbeat/docs/communitybeats.asciidoc).

## Building Beats from the Source

See our [CONTRIBUTING](CONTRIBUTING.md) file for information about setting up
your dev environment to build Beats from the source.
