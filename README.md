# slowloris.dart - Simple slowloris in Dart

## What is Slowloris?
Slowloris is basically an HTTP Denial of Service attack that affects threaded servers. It works like this:

1. We start making lots of HTTP requests.
2. We send headers periodically (every ~15 seconds) to keep the connections open.
3. We never close the connection unless the server does so. If the server closes a connection, we create a new one keep doing the same thing.

This exhausts the servers thread pool and the server can't reply to other people.

## Citation

If you found this work useful, please cite it as

```bibtex
@article{gkbrkslowloris,
  title = "Slowloris",
  author = "Gokberk Yaltirakli",
  journal = "github.com",
  year = "2015",
  url = "https://github.com/gkbrk/slowloris"
}
```

## How to install and run?

You can clone the git repo and run using Dart. Here's how:

### Prerequisites

You need to have Dart SDK installed. You can download it from [dart.dev](https://dart.dev/get-dart).

### Installation

* `git clone https://github.com/xphc-swissas/slowloris.git`
* `cd slowloris`
* `dart pub get`

### Running

* `dart run bin/slowloris.dart example.com`

Or you can compile it to a native executable:

* `dart compile exe bin/slowloris.dart -o slowloris`
* `./slowloris example.com`

## Configuration options
It is possible to modify the behaviour of slowloris with command-line
arguments. In order to get an up-to-date help document, just run
`dart run bin/slowloris.dart --help`.

* -p, --port
  * Port of webserver, usually 80
* -s, --sockets
  * Number of sockets to use in the test
* -v, --verbose
  * Increases logging (output on terminal)
* -u, --randuseragents
  * Randomizes user-agents with each request
* --sleeptime
  * Time to sleep between each header sent

## License
The code is licensed under the MIT License.
