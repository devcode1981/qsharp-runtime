namespace DecompositionTests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    // Note: These test cases run against only the sparse simulator for performance reasons. The
    // highly entangled states are ideal for sparse state simulation, where full state simulation takes
    // around 50x longer to run the same tests.

    @Test("SparseSimulator")
    operation VerifyH() : Unit {
        VerifyUnitaryAndFunctors(H, Reference.H);
    }

    @Test("SparseSimulator")
    operation VerifyS() : Unit {
        VerifyUnitaryAndFunctors(S, Reference.S);
    }

    @Test("SparseSimulator")
    operation VerifyT() : Unit {
        VerifyUnitaryAndFunctors(T, Reference.T);
    }

    @Test("SparseSimulator")
    operation VerifyX() : Unit {
        VerifyUnitaryAndFunctors(X, Reference.X);
    }

    @Test("SparseSimulator")
    operation VerifyY() : Unit {
        VerifyUnitaryAndFunctors(Y, Reference.Y);
    }

    @Test("SparseSimulator")
    operation VerifyZ() : Unit {
        VerifyUnitaryAndFunctors(Z, Reference.Z);
    }

    @Test("SparseSimulator")
    operation VerifyCNOT() : Unit {
        VerifyUnitaryAndFunctors2(CNOT, (q0, q1) => Controlled Reference.X([q0], q1));
    }

    @Test("SparseSimulator")
    operation VerifyCX() : Unit {
        VerifyUnitaryAndFunctors2(CX, (q0, q1) => Controlled Reference.X([q0], q1));
    }

    @Test("SparseSimulator")
    operation VerifyCY() : Unit {
        VerifyUnitaryAndFunctors2(CY, (q0, q1) => Controlled Reference.Y([q0], q1));
    }

    @Test("SparseSimulator")
    operation VerifyCZ() : Unit {
        VerifyUnitaryAndFunctors2(CZ, (q0, q1) => Controlled Reference.Z([q0], q1));
    }

    @Test("SparseSimulator")
    operation VerifyCCNOT() : Unit {
        VerifyUnitaryAndFunctors3(CCNOT, (q0, q1, q2) => Controlled Reference.X([q0, q1], q2));
    }

    @Test("SparseSimulator")
    operation VerifyRx() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => Rx(angle, q), q => Reference.R(PauliX, angle, q));
    }

    @Test("SparseSimulator")
    operation VerifyRy() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => Ry(angle, q), q => Reference.R(PauliY, angle, q));
    }

    @Test("SparseSimulator")
    operation VerifyRz() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => Rz(angle, q), q => Reference.R(PauliZ, angle, q));
    }

    @Test("SparseSimulator")
    operation VerifyR() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => R(PauliX, angle, q), q => Reference.R(PauliX, angle, q));
        VerifyUnitaryAndFunctors(q => R(PauliY, angle, q), q => Reference.R(PauliY, angle, q));
        VerifyUnitaryAndFunctors(q => R(PauliZ, angle, q), q => Reference.R(PauliZ, angle, q));
        VerifyUnitaryAndFunctors(q => R(PauliI, angle, q), q => Reference.R(PauliI, angle, q));
    }

    @Test("SparseSimulator")
    operation VerifyR1() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => R1(angle, q), q => Reference.R1(angle, q));
    }

    @Test("SparseSimulator")
    operation VerifySWAP() : Unit {
        VerifyUnitaryAndFunctors2(SWAP, Reference.SWAP);
    }

    @Test("SparseSimulator")
    operation VerifyExp() : Unit {
        // Use an angle that doesn't have any symmetries as a stand-in for broader validation.
        let angle = PI() / 7.0;
        VerifyUnitaryAndFunctors(q => Exp([PauliZ], angle, [q]), q => Reference.Exp([PauliZ], angle, [q]));
        VerifyUnitaryAndFunctors2((q0, q1) => Exp([PauliZ, size = 2], angle, [q0, q1]), (q0, q1) => Reference.Exp([PauliZ, size = 2], angle, [q0, q1]));
        VerifyUnitaryAndFunctors3((q0, q1, q2) => Exp([PauliZ, size = 3], angle, [q0, q1, q2]), (q0, q1, q2) => Reference.Exp([PauliZ, size = 3], angle, [q0, q1, q2]));
        VerifyUnitaryAndFunctors4((q0, q1, q2, q3) => Exp([PauliZ, size = 4], angle, [q0, q1, q2, q3]), (q0, q1, q2, q3) => Reference.Exp([PauliZ, size = 4], angle, [q0, q1, q2, q3]));
    }

    internal operation VerifyUnitaryAndFunctors(unitary : Qubit => Unit is Adj + Ctl, reference : Qubit => Unit is Adj + Ctl) : Unit {
        VerifyUnitary(unitary, reference, 8);
        VerifyUnitary(Adjoint unitary, Adjoint reference, 8);
        VerifyUnitary2((q0, q1) => Controlled unitary([q0], q1), (q0, q1) => Controlled reference([q0], q1), 7);
        VerifyUnitary2((q0, q1) => Controlled Adjoint unitary([q0], q1), (q0, q1) => Controlled Adjoint reference([q0], q1), 7);
    }

    internal operation VerifyUnitaryAndFunctors2(unitary : (Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit) => Unit is Adj + Ctl) : Unit {
        VerifyUnitary2(unitary, reference, 8);
        VerifyUnitary2(Adjoint unitary, Adjoint reference, 8);
        VerifyUnitary3((q0, q1, q2) => Controlled unitary([q0], (q1, q2)), (q0, q1, q2) => Controlled reference([q0], (q1, q2)), 7);
        VerifyUnitary3((q0, q1, q2) => Controlled Adjoint unitary([q0], (q1, q2)), (q0, q1, q2) => Controlled Adjoint reference([q0], (q1, q2)), 7);
    }

    internal operation VerifyUnitaryAndFunctors3(unitary : (Qubit, Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit, Qubit) => Unit is Adj + Ctl) : Unit {
        VerifyUnitary3(unitary, reference, 8);
        VerifyUnitary3(Adjoint unitary, Adjoint reference, 8);
        VerifyUnitary4((q0, q1, q2, q3) => Controlled unitary([q0], (q1, q2, q3)), (q0, q1, q2, q3) => Controlled reference([q0], (q1, q2, q3)), 7);
        VerifyUnitary4((q0, q1, q2, q3) => Controlled Adjoint unitary([q0], (q1, q2, q3)), (q0, q1, q2, q3) => Controlled Adjoint reference([q0], (q1, q2, q3)), 7);
    }

    internal operation VerifyUnitaryAndFunctors4(unitary : (Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl) : Unit {
        VerifyUnitary4(unitary, reference, 8);
        VerifyUnitary4(Adjoint unitary, Adjoint reference, 8);
        VerifyUnitary5((q0, q1, q2, q3, q4) => Controlled unitary([q0], (q1, q2, q3, q4)), (q0, q1, q2, q3, q4) => Controlled reference([q0], (q1, q2, q3, q4)), 7);
        VerifyUnitary5((q0, q1, q2, q3, q4) => Controlled Adjoint unitary([q0], (q1, q2, q3, q4)), (q0, q1, q2, q3, q4) => Controlled Adjoint reference([q0], (q1, q2, q3, q4)), 7);
    }

    internal operation VerifyUnitary(unitary : Qubit => Unit is Adj + Ctl, reference : Qubit => Unit is Adj + Ctl, limit : Int) : Unit {
        // Verify equality up to 8 controls.
        Reference.AssertOperationsEqualReferenced(1, qs => unitary(qs[0]),
            qs => reference(qs[0]));

        for numControls in 0..limit {
            Reference.AssertOperationsEqualReferenced(1 + numControls, qs => Controlled unitary(qs[1..numControls], qs[0]),
                qs => Controlled reference(qs[1..numControls], qs[0]));
        }
    }

    internal operation VerifyUnitary2(unitary : (Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit) => Unit is Adj + Ctl, limit : Int) : Unit {
        // Verify equality up to 8 controls.
        Reference.AssertOperationsEqualReferenced(2, qs => unitary(qs[0], qs[1]),
            qs => reference(qs[0], qs[1]));

        for numControls in 0..limit {
            Reference.AssertOperationsEqualReferenced(2 + numControls, qs => Controlled unitary(qs[2..(numControls + 1)], (qs[0], qs[1])),
                qs => Controlled reference(qs[2..(numControls + 1)], (qs[0], qs[1])));
        }
    }

    internal operation VerifyUnitary3(unitary : (Qubit, Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit, Qubit) => Unit is Adj + Ctl, limit : Int) : Unit {
        // Verify equality up to 8 controls.
        Reference.AssertOperationsEqualReferenced(3, qs => unitary(qs[0], qs[1], qs[2]),
            qs => reference(qs[0], qs[1], qs[2]));

        for numControls in 0..limit {
            Reference.AssertOperationsEqualReferenced(3 + numControls, qs => Controlled unitary(qs[3..(numControls + 2)], (qs[0], qs[1], qs[2])),
                qs => Controlled reference(qs[3..(numControls + 2)], (qs[0], qs[1], qs[2])));
        }
    }

    internal operation VerifyUnitary4(unitary : (Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl, limit : Int) : Unit {
        // Verify equality up to 8 controls.
        Reference.AssertOperationsEqualReferenced(4, qs => unitary(qs[0], qs[1], qs[2], qs[3]),
            qs => reference(qs[0], qs[1], qs[2], qs[3]));

        for numControls in 0..limit {
            Reference.AssertOperationsEqualReferenced(4 + numControls, qs => Controlled unitary(qs[4..(numControls + 3)], (qs[0], qs[1], qs[2], qs[3])),
                qs => Controlled reference(qs[4..(numControls + 3)], (qs[0], qs[1], qs[2], qs[3])));
        }
    }

    internal operation VerifyUnitary5(unitary : (Qubit, Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl, reference : (Qubit, Qubit, Qubit, Qubit, Qubit) => Unit is Adj + Ctl, limit : Int) : Unit {
        // Verify equality up to 8 controls.
        Reference.AssertOperationsEqualReferenced(5, qs => unitary(qs[0], qs[1], qs[2], qs[3], qs[4]),
            qs => reference(qs[0], qs[1], qs[2], qs[3], qs[4]));

        for numControls in 0..limit {
            Reference.AssertOperationsEqualReferenced(5 + numControls, qs => Controlled unitary(qs[5..(numControls + 4)], (qs[0], qs[1], qs[2], qs[3], qs[4])),
                qs => Controlled reference(qs[5..(numControls + 4)], (qs[0], qs[1], qs[2], qs[3], qs[4])));
        }
    }
}
