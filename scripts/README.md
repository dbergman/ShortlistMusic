# Swift Package Resolution Scripts

## Problem
When you delete DerivedData in Xcode, Swift packages can become "missing" even though `Package.resolved` exists. This requires manually reinstalling packages.

## Solution

### Option 1: Run Script Manually (Recommended)
After deleting DerivedData, run:
```bash
./scripts/resolve_packages.sh
```

This will automatically resolve all Swift packages from `Package.resolved` without needing to open Xcode.

### Option 2: Add as Build Phase (Automatic)
1. Open your project in Xcode
2. Select your project in the navigator
3. Select your target (e.g., "Shortlist")
4. Go to "Build Phases" tab
5. Click "+" and select "New Run Script Phase"
6. Drag it to the top (before "Compile Sources")
7. Add this script:
   ```bash
   "${SRCROOT}/../scripts/resolve_packages.sh"
   ```
8. Uncheck "For install builds only" (so it runs on every build)

### Option 3: Xcode Menu (Manual)
1. In Xcode, go to **File → Packages → Resolve Package Versions**
2. This will resolve packages from `Package.resolved`

## Why This Happens
Xcode stores resolved Swift packages in DerivedData. When you delete DerivedData (to fix build issues), Xcode loses track of the packages even though `Package.resolved` contains all the information needed to restore them.

## Prevention
- Always commit `Package.resolved` to git (it's already in the repo)
- The script uses `Package.resolved` to automatically restore packages
- This ensures consistent package versions across team members and after cleaning DerivedData

