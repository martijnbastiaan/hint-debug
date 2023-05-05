module Main where

import GHC
import GHC.Paths (libdir)
import GHC.Unit (baseUnitId)

main :: IO ()
main = do
  -- Don't pass in a home id. Results in:
  --
  --     hint-debug: panic! (the 'impossible' happened)
  --       GHC version 9.4.4:
  --             unsafeGetHomeUnit: No home unit
  --
  --     Please report this as a GHC bug:  https://www.haskell.org/ghc/reportabug
  --
  runGhc (Just libdir) $ do
    target <- guessTarget "Test.hs" Nothing Nothing
    setTargets [target]
    !_ <- load LoadAllTargets
    pure ()

  -- Home id ~ base. Results in:
  --
  --     hint-debug: panic! (the 'impossible' happened)
  --       GHC version 9.4.4:
  --             Unit unknown to the internal unit environment
  --
  --     unit (base)
  --     pprInternalUnitMap
  --       main (flags: main, Nothing) ->
  --     Call stack:
  --         CallStack (from HasCallStack):
  --           callStackDoc, called at compiler/GHC/Utils/Panic.hs:182:37 in ghc:GHC.Utils.Panic
  --           pprPanic, called at compiler/GHC/Unit/Env.hs:450:14 in ghc:GHC.Unit.Env
  --
  --     Please report this as a GHC bug:  https://www.haskell.org/ghc/reportabug
  runGhc (Just libdir) $ do
    target <- guessTarget "Test.hs" (Just baseUnitId) Nothing
    setTargets [target]
    !_ <- load LoadAllTargets
    pure ()
