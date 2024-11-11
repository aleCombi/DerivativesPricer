using Aqua
using Hedgehog
Aqua.test_all(Hedgehog; stale_deps=false, deps_compat=false)