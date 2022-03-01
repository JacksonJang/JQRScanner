var isSimulatorRunning: Bool = {
  #if swift(>=4.1)
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  #else
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      return true
    #else
      return false
    #endif
  #endif
}()
