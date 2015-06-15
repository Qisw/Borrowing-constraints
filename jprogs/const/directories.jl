# ------------------  Files and directories

## Directories
type dirParamS
  baseDir :: String
  modelDir :: String
  progDir  :: String
  # matDir :: String
  # outDir :: String

  # figDir :: String
  # tbDir :: String
  sharedDir :: String
  dataDir :: String
  # preambleFn :: String

  cpsDir :: String
  cpsProgDir :: String
end

function dirParamS()
  dirS = dirParamS("a", "a", "a", "a", "a",   "a", "a");

  if isdir("/users/lutz")
     dirS.baseDir = joinpath("/users", "lutz", "dropbox", "hc", "borrow_constraints");
  else
     dirS.baseDir = "/nas02/home/l/h/lhendri/bc";
    #  dirS.dbgFreq] = 0.1;    # Ensure that dbg is always low on the server
  end
  dirS.modelDir = joinpath(dirS.baseDir, "model1")
  dirS.progDir = joinpath(dirS.modelDir, "jprogs")

  # Put those that depend on set in var_fn etc
  # setStr = displayLH.printf("set%03i", setNo);
  # expStr = displayLH.printf("exp%03i", expNo);
  # dirS.matDir  = joinpath(dirS.modelDir, "mat", setStr, expStr)
  # dirS.outDir  = joinpath(dirS.modelDir, "out", setStr, expStr)
  # dirS.figDir  = dirS.outDir
  # dirS.tbDir   = dirS.outDir
  # Preamble data
  # dirS.preambleFn = joinpath(dirS.outDir, "preamble1.tex")

  dirS.sharedDir = joinpath(dirS.modelDir, "shared")
  dirS.dataDir = joinpath(dirS.baseDir, "data")


  dirS.cpsDir = joinpath(dirS.baseDir, "cps")
  dirS.cpsProgDir = joinpath(dirS.cpsDir, "progs");
  return dirS
end
