/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPAccountOnFileAttributeStatus) public enum AccountOnFileAttributeStatus: Int {
    @objc(OPReadOnly) case readOnly
    @objc(OPCanWrite) case canWrite
    @objc(OPMustWrite) case mustWrite
}
