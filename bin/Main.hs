{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (filterM)
import Control.Monad.IO.Class (liftIO, MonadIO)

import qualified GHC as Ghc
import qualified GHC.Paths as Ghc
import qualified GHC.Unit.Types as Ghc
import qualified GHC.Utils.Outputable as Ghc

guessTarget :: Ghc.GhcMonad m => String -> m Ghc.Target
guessTarget t = do
#if MIN_VERSION_ghc(9,4,0)
  Ghc.guessTarget t Nothing Nothing
#else
  Ghc.guessTarget t Nothing
#endif

print' :: (MonadIO m, Ghc.Outputable a) => m a -> m ()
print' action = do
  res <- action
  liftIO $ putStrLn (Ghc.showPprUnsafe res)

getLoadedModSummaries :: Ghc.GhcMonad m => m [Ghc.ModSummary]
getLoadedModSummaries = do
  modGraph <- Ghc.getModuleGraph
  let modSummaries = Ghc.mgModSummaries modGraph
  filterM (Ghc.isLoaded . Ghc.ms_mod_name) modSummaries

#if MIN_VERSION_ghc(9,4,0)
mkModule :: Ghc.GhcMonad m => String -> m (Ghc.GenModule Ghc.UnitId)
mkModule nm = do
    df <- Ghc.getSessionDynFlags
    pure $ Ghc.mkModule (Ghc.homeUnitId_ df) (Ghc.mkModuleName nm)
#else
mkModule :: Ghc.GhcMonad m => String -> m Ghc.ModuleName
mkModule nm =
    pure $ Ghc.mkModuleName nm
#endif

main :: IO ()
main = do
  Ghc.runGhc (Just Ghc.libdir) $ do
    Ghc.setSessionDynFlags =<< Ghc.getSessionDynFlags

    liftIO $ putStrLn "Adding Foo as a target, and executing 'LoadAllTargets'.."
    fooTarget <- guessTarget "Foo.hs"
    Ghc.addTarget fooTarget
    print' $ Ghc.load Ghc.LoadAllTargets
    print' getLoadedModSummaries

    liftIO $ putStrLn "Adding Bar as a target, and executing 'LoadUpTo m'.."
    barTarget <- guessTarget "Bar.hs"
    Ghc.addTarget barTarget
    m <- mkModule "Bar"
    print' $ Ghc.load (Ghc.LoadUpTo m)
    print' getLoadedModSummaries
