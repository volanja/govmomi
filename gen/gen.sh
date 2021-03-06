#!/bin/bash

# Copyright (c) 2014 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

generate() {
  dst="$1"
  wsdl="$2"
  modl="$3"

  pkgs=(types methods)
  if [ -n "$modl" ] ; then
    pkgs+=(mo)
  fi

  for p in "${pkgs[@]}"
  do
    mkdir -p "$dst/$p"
  done

  echo "generating $dst/..."

  bundle exec ruby gen_from_wsdl.rb "$dst" "$wsdl"
  if [ -n "$modl" ] ; then
    bundle exec ruby gen_from_vmodl.rb "$dst" "$wsdl" "$modl"
  fi

  for p in "${pkgs[@]}"
  do
    pushd "$dst/$p" >/dev/null
    goimports -w ./*.go
    go install
    popd >/dev/null
  done
}

# ./sdk/ contains the contents of wsdl.zip from vimbase build 17097359 (vSphere 7.0U1)

generate "../vim25" "vim" "./rbvmomi/vmodl.db" # from github.com/vmware/rbvmomi@v2.4.1
generate "../pbm" "pbm"
generate "../vslm" "vslm"
generate "../sms" "sms"

# ./sdk/ contains the files eam-messagetypes.xsd and eam-types.xsd from
# eam-wsdl.zip, from eam-vcenter build 17073099 (vSphere 7.0U1), a
# dependency component of the aforementioned vimbase build 17097359.
#
# Please note the EAM files are also available at the following, public URL --
# http://bit.ly/eam-sdk, therefore the WSDL resource for EAM are in fact
# public. A specific build was obtained in order to match the same build as
# used for the file from above, wsdl.zip.
COPYRIGHT_DATE_RANGE=2021 generate "../eam" "eam"

# originally generated, then manually pruned as there are several vim25 types that are duplicated.
# generate "../lookup" "lookup" # lookup.wsdl from build 4571810
# originally generated, then manually pruned.
# generate "../ssoadmin" "ssoadmin" # ssoadmin.wsdl from PSC
