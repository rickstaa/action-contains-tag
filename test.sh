test="refs/tags/v1.0.0"
if [[ "${test}" == 'refs/tags/'* ]]; then
    echo "contained"
else
    echo "not contained"
fi
