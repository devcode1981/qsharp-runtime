// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Applies the controlled-Z (CZ) gate to a pair of qubits.
    ///
    /// $$
    /// \begin{align}
    ///     1 & 0 & 0 & 0 \\\\
    ///     0 & 1 & 0 & 0 \\\\
    ///     0 & 0 & 1 & 0 \\\\
    ///     0 & 0 & 0 & -1
    /// \end{align},
    /// $$
    /// where rows and columns are organized as in the quantum concepts guide.
    ///
    /// # Input
    /// ## control
    /// Control qubit for the CZ gate.
    /// ## target
    /// Target qubit for the CZ gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled Z([control], target);
    /// ```
    internal operation ApplyControlledZ (control : Qubit, target : Qubit) : Unit is Adj {
        body (...) {
            ApplyUncontrolledRzz(PI() / 2.0, control, target);
            ApplyUncontrolledRz(-PI() / 2.0, control);
            ApplyUncontrolledRz(-PI() / 2.0, target);
        }
        adjoint self;
    }
}