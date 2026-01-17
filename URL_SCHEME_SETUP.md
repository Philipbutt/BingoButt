# URL Scheme Configuration

To enable deep linking for shared Bingo cards, you need to configure URL schemes in your Xcode project:

## Steps:

1. Open your Xcode project
2. Select the **Bingo** target
3. Go to the **Info** tab
4. Expand **URL Types** section
5. Click the **+** button to add a new URL Type
6. Configure as follows:
   - **Identifier**: `com.phil.Bingo`
   - **URL Schemes**: Add `bingocard` and `bingocardmaker`
   - **Role**: `Editor`

Alternatively, if using Info.plist directly, add this to your Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.phil.Bingo</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bingocard</string>
            <string>bingocardmaker</string>
        </array>
    </dict>
</array>
```

## How it works:

1. When a user shares a card, it includes a deep link URL like: `bingocard://add?card=<base64encodedcarddata>`
2. When someone clicks the link:
   - If the app is installed: The app opens and adds the card to "My Cards"
   - If the app is not installed: The user will need to manually install it first (you can add App Store redirect logic)

## Testing:

You can test the deep link by opening Safari on your device and entering:
`bingocard://add?card=<sometestdata>`

The app should open and attempt to decode the card data.
