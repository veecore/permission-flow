use swift_rs::SwiftLinker;

const MINIMUM_MACOS_VERSION: &str = "12.0";
const SWIFT_PACKAGE_NAME: &str = "PermissionFlowShimFFI";
const SWIFT_PACKAGE_PATH: &str = "PermissionFlowShim";

fn main() {
    println!("cargo:rerun-if-changed=PermissionFlow");
    println!("cargo:rerun-if-changed=PermissionFlowShim");

    let is_docs_rs = std::env::var_os("DOCS_RS").is_some();
    let is_macos = std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("macos");
    if is_docs_rs || !is_macos {
        return;
    }

    println!("cargo:rustc-link-arg=-Wl,-rpath,/usr/lib/swift");

    SwiftLinker::new(MINIMUM_MACOS_VERSION)
        .with_package(SWIFT_PACKAGE_NAME, SWIFT_PACKAGE_PATH)
        .link();
}
