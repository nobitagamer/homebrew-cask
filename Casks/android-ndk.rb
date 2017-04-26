cask 'android-ndk' do
  version '10e'
  sha256 'e205278fba12188c02037bfe3088eba34d8b5d96b1e71c8405f9e6e155a3bce4'

  # dl.google.com/android/repository/android-ndk was verified as official when first introduced to the cask
  url "https://dl.google.com/android/repository/android-ndk-r#{version}-darwin-x86_64.zip"
  name 'Android NDK'
  homepage 'https://developer.android.com/ndk/'

  conflicts_with cask: 'crystax-ndk'

  # shim script (https://github.com/caskroom/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/ndk_exec.sh"
  preflight do
    FileUtils.ln(staged_path.to_s, "#{HOMEBREW_PREFIX}/opt/android-ndk", force: true)

    IO.write shimscript, <<-EOS.undent
      #!/bin/bash
      readonly executable="#{staged_path}/android-ndk-r#{version}/$(basename ${0})"
      test -f "${executable}" && exec "${executable}" "${@}"
    EOS
    set_permissions shimscript, '+x'
  end

  %w[
    ndk-build
    ndk-depends
    ndk-gdb
    ndk-stack
    ndk-which
  ].each { |link_name| binary shimscript, target: link_name }

  caveats <<-EOS.undent
   You may want to add to your profile:
      'export ANDROID_NDK_HOME="#{HOMEBREW_PREFIX}/opt/android-ndk"'
  EOS
end
