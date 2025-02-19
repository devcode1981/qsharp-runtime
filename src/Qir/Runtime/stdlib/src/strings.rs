// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::update_counts;
use crate::Pauli;
use num_bigint::BigInt;
use std::{
    ffi::{CStr, CString},
    os::raw::{c_char, c_double},
    rc::Rc,
};

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_create(str: *mut c_char) -> *const CString {
    let cstring = CString::new(CStr::from_ptr(str).to_owned()).expect("Failed to create %String");
    Rc::into_raw(Rc::new(cstring))
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_get_data(str: *const CString) -> *const c_char {
    (*str).as_bytes_with_nul().as_ptr().cast::<i8>()
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_get_length(str: *const CString) -> u32 {
    (*str)
        .as_bytes()
        .len()
        .try_into()
        .expect("String length is too large for 32-bit integer.")
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_update_reference_count(
    str: *const CString,
    update: i32,
) {
    update_counts(str, update, false);
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_concatenate(
    s1: *const CString,
    s2: *const CString,
) -> *const CString {
    let mut new_str = (*s1).clone().into_bytes();
    new_str.extend_from_slice((*s2).to_bytes());

    Rc::into_raw(Rc::new(
        CString::new(new_str).expect("Unable to convert string"),
    ))
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_equal(
    s1: *const CString,
    s2: *const CString,
) -> bool {
    *s1 == *s2
}

pub(crate) fn convert<T>(input: &T) -> *const CString
where
    T: ToString,
{
    unsafe {
        __quantum__rt__string_create(
            CString::new(input.to_string())
                .expect("Unable to allocate string for conversion.")
                .as_bytes_with_nul()
                .as_ptr() as *mut i8,
        )
    }
}

#[no_mangle]
pub extern "C" fn __quantum__rt__int_to_string(input: i64) -> *const CString {
    convert(&input)
}

pub(crate) fn double_to_string(input: c_double) -> String {
    if (input.floor() - input.ceil()).abs() < c_double::EPSILON {
        // The value is a whole number, which by convention is displayed with one decimal point
        // to differentiate it from an integer value.
        format!("{:.1}", input)
    } else {
        format!("{}", input)
    }
}

#[no_mangle]
pub extern "C" fn __quantum__rt__double_to_string(input: c_double) -> *const CString {
    convert(&double_to_string(input))
}

#[no_mangle]
pub extern "C" fn __quantum__rt__bool_to_string(input: bool) -> *const CString {
    convert(&input)
}

#[no_mangle]
pub extern "C" fn __quantum__rt__pauli_to_string(input: Pauli) -> *const CString {
    match input {
        Pauli::I => convert(&"PauliI"),
        Pauli::X => convert(&"PauliX"),
        Pauli::Y => convert(&"PauliY"),
        Pauli::Z => convert(&"PauliZ"),
    }
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_to_string(input: *const BigInt) -> *const CString {
    convert(&*input)
}

#[cfg(test)]
mod tests {
    use std::mem::ManuallyDrop;

    use super::*;
    use crate::bigints::{
        __quantum__rt__bigint_create_i64, __quantum__rt__bigint_update_reference_count,
    };

    #[test]
    fn test_string_create() {
        let orig_str = CString::new("Test String").unwrap();
        let str = unsafe {
            __quantum__rt__string_create(
                orig_str.as_bytes_with_nul().as_ptr() as *mut std::os::raw::c_char
            )
        };
        // string_create should make a copy, not consume original.
        assert_eq!(orig_str.to_str().unwrap(), "Test String");
        drop(orig_str);
        assert!(!str.is_null());
        unsafe {
            // Copy should be valid after original is dropped.
            assert_eq!(
                Rc::from_raw(str)
                    .to_str()
                    .expect("Unable to convert input string"),
                "Test String"
            );
        }
    }

    #[test]
    fn test_string_get_data() {
        let str = unsafe {
            __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8
            )
        };
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str))
                    .to_str()
                    .unwrap(),
                "Data"
            );
        }
        unsafe {
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_get_length() {
        let str = unsafe {
            __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8
            )
        };
        assert_eq!(unsafe { __quantum__rt__string_get_length(str) }, 4);
        unsafe {
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_update_reference_count() {
        unsafe {
            let str = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let rc = ManuallyDrop::new(Rc::from_raw(str));
            assert_eq!(Rc::strong_count(&rc), 1);
            __quantum__rt__string_update_reference_count(str, 2);
            assert_eq!(Rc::strong_count(&rc), 3);
            __quantum__rt__string_update_reference_count(str, -2);
            assert_eq!(Rc::strong_count(&rc), 1);
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_concatenate() {
        unsafe {
            let str1 = __quantum__rt__string_create(
                CString::new("Hello").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str2 = __quantum__rt__string_create(
                CString::new(", World!")
                    .unwrap()
                    .as_bytes_with_nul()
                    .as_ptr() as *mut i8,
            );
            let str3 = __quantum__rt__string_concatenate(str1, str2);
            // Concatenated string should have combined value.
            let rc = ManuallyDrop::new(Rc::from_raw(str3));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "Hello, World!"
            );
            __quantum__rt__string_update_reference_count(str3, -1);
            // After decrement and drop, original strings should still be valid.
            let rc = ManuallyDrop::new(Rc::from_raw(str2));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                ", World!"
            );
            __quantum__rt__string_update_reference_count(str2, -1);
            let rc = ManuallyDrop::new(Rc::from_raw(str1));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "Hello"
            );
            __quantum__rt__string_update_reference_count(str1, -1);
        }
    }

    #[test]
    fn test_string_equal() {
        unsafe {
            let str1 = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str2 = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str3 = __quantum__rt__string_create(
                CString::new("Not Data")
                    .unwrap()
                    .as_bytes_with_nul()
                    .as_ptr() as *mut i8,
            );
            assert!(__quantum__rt__string_equal(str1, str2));
            assert!(!__quantum__rt__string_equal(str1, str3));
            // Confirm data is still valid and not consumed by the check.
            let rc = ManuallyDrop::new(Rc::from_raw(str3));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "Not Data"
            );
            __quantum__rt__string_update_reference_count(str3, -1);
            let rc = ManuallyDrop::new(Rc::from_raw(str2));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                "Data"
            );
            __quantum__rt__string_update_reference_count(str2, -1);
            let rc = ManuallyDrop::new(Rc::from_raw(str1));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "Data"
            );
            __quantum__rt__string_update_reference_count(str1, -1);
        }
    }

    #[test]
    fn test_to_string() {
        let input0 = 42;
        let str0 = __quantum__rt__int_to_string(input0);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str0))
                    .to_str()
                    .unwrap(),
                "42"
            );
        }
        let input1 = 4.2;
        let str1 = __quantum__rt__double_to_string(input1);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "4.2"
            );
        }
        let input1_1 = 4.0;
        let str1_1 = __quantum__rt__double_to_string(input1_1);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1_1))
                    .to_str()
                    .unwrap(),
                "4.0"
            );
        }
        let input1_2 = 0.1;
        let str1_2 = __quantum__rt__double_to_string(input1_2);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1_2))
                    .to_str()
                    .unwrap(),
                "0.1"
            );
        }
        let input1_3 = 0.100_000_000_01;
        let str1_3 = __quantum__rt__double_to_string(input1_3);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1_3))
                    .to_str()
                    .unwrap(),
                "0.10000000001"
            );
        }
        let input2 = false;
        let str2 = __quantum__rt__bool_to_string(input2);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                "false"
            );
        }
        let input3 = Pauli::Z;
        let str3 = __quantum__rt__pauli_to_string(input3);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "PauliZ"
            );
        }
        let input4 = __quantum__rt__bigint_create_i64(400_002);
        unsafe {
            let str4 = __quantum__rt__bigint_to_string(input4);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str4))
                    .to_str()
                    .unwrap(),
                "400002"
            );

            __quantum__rt__string_update_reference_count(str0, -1);
            __quantum__rt__string_update_reference_count(str1, -1);
            __quantum__rt__string_update_reference_count(str1_1, -1);
            __quantum__rt__string_update_reference_count(str1_2, -1);
            __quantum__rt__string_update_reference_count(str1_3, -1);
            __quantum__rt__string_update_reference_count(str2, -1);
            __quantum__rt__string_update_reference_count(str3, -1);
            __quantum__rt__string_update_reference_count(str4, -1);
            __quantum__rt__bigint_update_reference_count(input4, -1);
        }
    }
}
