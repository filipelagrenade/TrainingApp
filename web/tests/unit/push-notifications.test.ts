import { describe, expect, it } from "vitest";

import { urlBase64ToUint8Array } from "@/lib/use-push-notifications";

// Standard VAPID applicationServerKey decoding: base64url → raw bytes.
describe("urlBase64ToUint8Array", () => {
  it("decodes an unpadded base64url string to the right bytes", () => {
    // "hello" → base64 "aGVsbG8=" → base64url "aGVsbG8" (no padding).
    const bytes = urlBase64ToUint8Array("aGVsbG8");
    expect(Array.from(bytes)).toEqual([104, 101, 108, 108, 111]);
  });

  it("handles base64url-specific chars (- and _) and re-adds padding", () => {
    // Bytes [251, 255] encode to base64 "+/8=", base64url "-_8".
    const bytes = urlBase64ToUint8Array("-_8");
    expect(Array.from(bytes)).toEqual([251, 255]);
  });

  it("round-trips a realistic 65-byte VAPID key length", () => {
    const raw = new Uint8Array(65).map((_, i) => (i * 7) % 256);
    let binary = "";
    for (const byte of raw) {
      binary += String.fromCharCode(byte);
    }
    const base64url = btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
    expect(Array.from(urlBase64ToUint8Array(base64url))).toEqual(Array.from(raw));
  });
});
