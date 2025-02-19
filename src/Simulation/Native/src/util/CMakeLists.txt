# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

add_executable(tinymatrix_test tinymatrix_test.cpp)
add_executable(diagmatrix_test diagmatrix_test.cpp)
add_executable(bitops_test bitops_test.cpp)
add_executable(openmp_test openmp_test.cpp)
add_executable(argmaxnrm2_test argmaxnrm2_test.cpp)
add_executable(bititerator_test bititerator_test.cpp)
add_executable(cpuid_test cpuid_test.cpp)

target_link_libraries(tinymatrix_test ${SPECTRE_LIBS})
target_link_libraries(diagmatrix_test ${SPECTRE_LIBS})
target_link_libraries(bitops_test ${SPECTRE_LIBS})
target_link_libraries(openmp_test Microsoft.Quantum.Simulator.Runtime ${SPECTRE_LIBS})
target_link_libraries(argmaxnrm2_test ${SPECTRE_LIBS})
target_link_libraries(bititerator_test ${SPECTRE_LIBS})
target_link_libraries(cpuid_test ${SPECTRE_LIBS})

add_test(NAME tinymatrix COMMAND  ./tinymatrix_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME diagmatrix COMMAND  ./diagmatrix_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME bitops COMMAND   ./bitops_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME openmp COMMAND  ./openmp_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME argmaxnrm2 COMMAND  ./argmaxnrm2_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME bititerator COMMAND  ./bititerator_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME cpuid_test COMMAND  ./cpuid_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

install(TARGETS tinymatrix_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS diagmatrix_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS bitops_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS openmp_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS argmaxnrm2_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS bititerator_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")
install(TARGETS cpuid_test RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")

