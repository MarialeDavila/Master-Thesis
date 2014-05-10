project(test)
cmake_minimum_required(VERSION 2.6)
find_package(OpenCV REQUIRED)

SET(SOURCE
  main.cpp
)

SET(HEADERS
  segment/segment-graph.h
  segment/disjoint-set.h
)

add_executable(${PROJECT_NAME} ${SOURCE} ${HEADERS})
target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS})
