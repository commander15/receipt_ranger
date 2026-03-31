mkdir -p build/apk
for apk in build/app/outputs/flutter-apk/*.apk; do
filename=$(basename "$apk")
newname="${filename//app/release/ReceiptRanger-v${{ steps.version.outputs.version }}}"
newname="${newname//.apk/-${filename##*-}.apk}"  # Preserve ABI suffix
cp "$apk" "build/apk/$newname"
echo "Renamed: $newname"
done
