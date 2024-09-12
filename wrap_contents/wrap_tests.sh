#!/usr/bin/env bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'
load '../test/test_helper/bats-file/load'

# Create a temporary scratch directory for the shell script to work in.
setup() {
  BATS_TMPDIR=$(temp_make --prefix 'wrapping-')

  # The comments below disable a shellcheck warning that would
  # otherwise appear on both these saying that these variables
  # appear to be unused. They *are* used, but in the bats-file
  # code, so shellcheck can't tell they're being used, which is
  # why I'm ignoring those checks for these two variables, and
  # BATSLIB_TEMP_PRESERVE_ON_FAILURE a little farther down.
  # shellcheck disable=SC2034
  BATSLIB_FILE_PATH_REM="#${BATS_TMPDIR}"
  # shellcheck disable=SC2034
  BATSLIB_FILE_PATH_ADD='<temp>'

  # Comment out the next line if you want to see where the temp files
  # are being created.
  echo "Bats temp directory: $BATS_TMPDIR"

  # This tells bats to preserve (i.e., not delete)
  # the temp files generated for failing tests. This might be 
  # useful in trying to figure out what happened when a test fails.
  # It also could potentially clutter up the drive with a bunch
  # of temp files, so you might want to disable it when you're not
  # in "full-on debugging" mode.
  # shellcheck disable=SC2034
  BATSLIB_TEMP_PRESERVE_ON_FAILURE=1

  # Copy the script and archive file to the temp directory
  # and `cd` there to do all the testing work.
  cp -r wrap_contents.sh simple_example chart_example "$BATS_TMPDIR"
  cd "$BATS_TMPDIR" || exit 1
}

# Remove the temporary scratch directory to clean up after ourselves.
teardown() {
  # Remove the temporary scratch directory to clean up
  # after ourselves.
  temp_del "$BATS_TMPDIR"
}

# If this test fails, your script file doesn't exist, or there's
# a typo in the name, or it's in the wrong directory, etc.
@test "wrap_contents.sh exists" {
  assert_file_exist "wrap_contents.sh"
}

# If this test fails, your script isn't executable.
@test "wrap_contents.sh is executable" {
  assert_file_executable "wrap_contents.sh"
}

# If this test fails, your script either didn't run at all, or it
# generated some sort of error when it ran.
@test "wrap_contents.sh runs successfully" {
  cd simple_example
  run ../wrap_contents.sh test_middle.txt test_ends result.html
  assert_success
}

# If this test fails, your script didn't generate the correct output
# for test_middle.txt and test_ends. You probably want to run your
# script by hand and compare the results to the expected output
# in test_output.html.
@test "wrap_contents.sh generates correct simple output" {
  cd simple_example
  ../wrap_contents.sh test_middle.txt test_ends result.html
  run diff -wbB test_output.html result.html
  assert_success
}

# If this test fails, your script didn't generate the correct output
# for the plotting example. You probably want to run your script by
# hand and compare the results to the expected output in
# chart_example/sample_chart.html
@test "wrap_contents.sh generates correct plot output" {
  cd chart_example
  ../wrap_contents.sh meats.txt bread chart_result.html
  run diff -wbB sample_chart.html chart_result.html
  assert_success
}
