archs=({{ with tree "cvmfs/client" | explode -}}
{{range $key, $value := . -}}
{{ $value.rsnt_arch }} {{ end -}} {{ end -}})
if [[ " ${archs[@]} " =~ " sse3 " ]]; then
    export RSNT_ARCH="sse3"
elif [[ " ${archs[@]} " =~ " avx " ]]; then
    export RSNT_ARCH="avx"
elif [[ " ${archs[@]} " =~ " avx2 " ]]; then
    export RSNT_ARCH="avx2"
elif [[ " ${archs[@]} " =~ " avx512 " ]]; then
    export RSNT_ARCH="avx512"
fi
