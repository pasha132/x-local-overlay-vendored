#!/usr/bin/env bash
#

set -ue

declare SCRIPT_DIR
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR

# shellcheck source=/dev/null
source "${SCRIPT_DIR}"/lib.sh

declare -ra CURL_OPTIONS=(
	"--fail"
	"--silent"
	"--show-error"
	"--retry" "5"
	"--retry-delay" "0"
	"--retry-max-time" "120"
	"--connect-timeout" "5"
	"--max-time" "300"
	"--retry-connrefused"
	"--location"
)

cd "$(dirname "${0}")"

declare -r PN="${1}"
declare -r PV="${2}"
declare -r SRC_URI="${3}"
declare -r P="${PN}-${PV}"
declare -r S="${4:-${P}}"

declare tmpdir
tmpdir="$(mktemp -d)" || die "Failed to create temp dir"
readonly tmpdir

function cleanup {
    rm -rf "${tmpdir}"
}

trap cleanup EXIT

declare -r archivedir="${PWD}/dep-archives"
export GOMODCACHE="${PWD}/go-mod"

mkdir -p "${archivedir}" || die "Failed to create ${archivedir}"

declare file
file="$(basename "${SRC_URI}")"
readonly file

declare -r src="${tmpdir}/${file}"

einfo "Building vendor for ${P} from source ${SRC_URI}"

einfo "Fetching source"
curl "${CURL_OPTIONS[@]}" --output "${src}" "${SRC_URI}" || die "curl failed"

einfo "Extracting source"
cd "${tmpdir}" || die "cd ${tmpdir} failed"
tar --extract --file "${src}" || die

pushd "${S}" || die "pushd ${S} failed"
einfo "Downloading vendor"
go mod vendor || die
popd

einfo "Packing vendor"
tar --create --file "${P}-vendor.tar.xz" --auto-compress "$S/vendor" || die

mv "${P}-vendor.tar.xz" "${archivedir}" || die "Failed to move ${P}-vendor.tar.xz to archivedir"
