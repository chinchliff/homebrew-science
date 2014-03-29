require "formula"

class Phlawd < Formula

  homepage "https://github.com/chinchliff/phlawd/"
  url "https://github.com/chinchliff/phlawd/releases/download/3.4a/phlawd_3.4a_src_with_sqlitewrapped_1.3.1.tar.gz"
  sha1 "116158ee33b6c33e83a585b26481c5497c7b4ac7"

  fails_with :clang do
    build 503
    cause <<-eos
      PHLAWD requires openmp support, which is not available in clang.
      Currently, PHLAWD can only be compiled with gcc > 4.2.
    eos
  end

  fails_with :llvm do
    cause "The llvm compiler is not supported."
  end

  # correct the makefile to look for dependencies where brew installs them
  patch :DATA

  depends_on "mafft"
  depends_on "muscle"
  depends_on "quicktree"
  depends_on "sqlite"

  def install

    # compile sqlitewrapped: a dependency included here since it uncommon and unmaintained
    system "make", "-C", "sqlitewrapped-1.3.1"

    # compile phlawd
    system "make", "-C", "src", "-f", "Makefile.MAC"
    system "mv", "src/PHLAWD", "#{prefix}/"
    install_target="/usr/local/bin/phlawd"
    if File.file?(install_target)
      system "mv", install_target, install_target + "_previous"
    end
    system "ln", "-s", "#{prefix}/PHLAWD", install_target
  end

  test do
    # currently developing tests, they will be included in next release
    system "PHLAWD"
  end
end

__END__
diff --git a/src/Makefile.MAC b/src/Makefile.MAC
index a48def0..4b683dd 100644
--- a/src/Makefile.MAC
+++ b/src/Makefile.MAC
@@ -91,8 +91,7 @@ all: PHLAWD
 # Tool invocations
 PHLAWD: $(OBJS) $(USER_OBJS)
 	@echo 'Building target: $@'
-#	$(CC) $(CFLAGS) -L../deps/mac -L/usr/local/lib -L/usr/lib -o "PHLAWD" $(OBJS) $(USER_OBJS) $(LIBS)
-	$(CC) $(CFLAGS) -L../deps/mac -L/usr/local/lib -o "PHLAWD" $(OBJS) $(USER_OBJS) $(LIBS)
+	$(CC) $(CFLAGS) -L/usr/local/lib -I/usr/local/include -L../sqlitewrapped-1.3.1 -I../sqlitewrapped-1.3.1 -o "PHLAWD" $(OBJS) $(USER_OBJS) $(LIBS)
 	@echo 'Finished building target: $@'
 	@echo ' '
 
