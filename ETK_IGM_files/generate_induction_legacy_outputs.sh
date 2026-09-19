#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
testdata_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_revision=4f4c702e8a770372393ec42eb6985110be142ec9
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/grhayl-induction-legacy.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

git -C "$work_dir" init -q producer
git -C "$work_dir/producer" remote add origin \
  https://bitbucket.org/zach_etienne/wvuthorns.git
git -C "$work_dir/producer" fetch -q --depth=1 origin "$source_revision"
git -C "$work_dir/producer" checkout -q --detach FETCH_HEAD

source_file="$work_dir/producer/IllinoisGRMHD/src/Lorenz_psi6phi_rhs__add_gauge_terms_to_A_i_rhs.C"
g++ -std=c++11 -O2 -Wno-unknown-pragmas \
  -include "$script_dir/induction_legacy_standalone.hpp" \
  "$source_file" "$script_dir/induction_legacy_standalone_main.cc" \
  -o "$work_dir/generate"

cp "$testdata_dir/ET_Legacy/ET_Legacy_induction_gauge_rhs_input.bin" "$work_dir/"
cp "$testdata_dir/ET_Legacy/ET_Legacy_induction_gauge_rhs_input_pert.bin" "$work_dir/"
(cd "$work_dir" && ./generate)

if command -v clang++ >/dev/null 2>&1; then
  clang++ -std=c++11 -O2 -Wno-unknown-pragmas \
    -include "$script_dir/induction_legacy_standalone.hpp" \
    "$source_file" "$script_dir/induction_legacy_standalone_main.cc" \
    -o "$work_dir/generate-clang"
  mkdir "$work_dir/clang"
  cp "$work_dir/"*input*.bin "$work_dir/clang/"
  (cd "$work_dir/clang" && ../generate-clang)
  cmp "$work_dir/ET_Legacy_induction_gauge_rhs_output.bin" \
    "$work_dir/clang/ET_Legacy_induction_gauge_rhs_output.bin"
  cmp "$work_dir/ET_Legacy_induction_gauge_rhs_output_pert.bin" \
    "$work_dir/clang/ET_Legacy_induction_gauge_rhs_output_pert.bin"
fi

install -m 0644 "$work_dir/ET_Legacy_induction_gauge_rhs_output.bin" \
  "$testdata_dir/ET_Legacy/ET_Legacy_induction_gauge_rhs_output.bin"
install -m 0644 "$work_dir/ET_Legacy_induction_gauge_rhs_output_pert.bin" \
  "$testdata_dir/ET_Legacy/ET_Legacy_induction_gauge_rhs_output_pert.bin"
