// Copyright 2013, Juan Carlos Niebles.

#include <vector>
#include <iostream>
#include <fstream>
#include "segment/disjoint-set.h"
#include "segment/segment-graph.h"
#include "opencv2/opencv.hpp"

int main(int argc, char *argv[]) {
  if (argc < 3)
    exit(-1);
  // Open video file.
  cv::VideoCapture video(argv[1]);
  // Check if we succeeded.
  if (!video.isOpened())
    return -2;
  // Keep track of frame number.
  int frame_number = 0;
  // Create variables to store current and previous frames.
  cv::Mat current_frame, previous_frame, video_frame;
  cv::Mat display_corners_image, display_optical_flow_image;
  // Variables to hold detected corners.
  cv::GoodFeaturesToTrackDetector feature_detector(1000, 0.1, 1);
  // Main loop on all video frames.
  for (;;) {
    if (frame_number == 0) {
      // Grab first frame.
      if (!video.read(video_frame))
        exit(-3);
      cv::cvtColor(video_frame, previous_frame, CV_BGR2GRAY);
      frame_number++;
    } else {
      current_frame.copyTo(previous_frame);
    }
    // Compute first set of corners.
    std::vector<cv::KeyPoint> previous_corners;
    std::vector<cv::Point2f> previous_points, next_points;
    feature_detector.detect(previous_frame, previous_corners);
    // Convert corner keypoints to points for optical flow computation.
    for (unsigned int i = 0; i < previous_corners.size(); i++) {
      previous_points.push_back(previous_corners[i].pt);
    }
    cv::drawKeypoints(video_frame, previous_corners, display_corners_image);
    cv::imshow("previous corners", display_corners_image);
    // Grab a new frame from video.
    if (!video.read(video_frame))
      break;
    frame_number++;
    cv::cvtColor(video_frame, current_frame, CV_BGR2GRAY);

    // Compute Optical Flow.
    cv::Mat optical_flow_status, optical_flow_error;
    cv::calcOpticalFlowPyrLK(previous_frame, current_frame, previous_points,
                             next_points, optical_flow_status,
                             optical_flow_error);
    std::cout << "numero de puntos: " << previous_corners.size()
              << std::endl;
    // Get motion vectors.
    std::vector<cv::Point2f> motion_vectors;
    for (unsigned int i = 0; i < previous_corners.size(); i++) {
      motion_vectors.push_back(previous_points.at(i) - next_points.at(i));
    }
    // Compute distance matrix between every pair of points.
    unsigned int number_corners = previous_corners.size();
    cv::Mat motion_distances(number_corners, number_corners, CV_32F);
    cv::Mat spatial_distances(number_corners, number_corners, CV_32F);
    for (unsigned int i = 0; i < number_corners; i++) {
      for (unsigned int j = 0; j < number_corners; j++) {
        // Compute motion distance.
        cv::Point2f diff = motion_vectors.at(i) - motion_vectors.at(j);
        motion_distances.at<float>(i, j) = sqrt(diff.x*diff.x + diff.y*diff.y);
        // Compute spatial distance.
        cv::Point2f spatial_diff = previous_points.at(i)
                                   - previous_points.at(j);
        spatial_distances.at<float>(i, j) = sqrt(spatial_diff.x*spatial_diff.x
                                                 + spatial_diff.y*spatial_diff.y);
      }
    }
    // Choose nearest neighbors at each point location.
    cv::Mat chosen_distances(spatial_distances.size(), CV_32F, cv::Scalar(-1));
    cv::Mat sorted_indexes;
    cv::sortIdx(spatial_distances, sorted_indexes,
                CV_SORT_EVERY_ROW + CV_SORT_ASCENDING);
    for (unsigned int i = 0; i < number_corners; i++) {
      for (unsigned int j = 1; j < 30; j++) {
        int neighbor_index = sorted_indexes.at<int>(i, j);
        float neighbor_distance = motion_distances.at<float>(i, neighbor_index);
        chosen_distances.at<float>(i, neighbor_index) = neighbor_distance;
        chosen_distances.at<float>(neighbor_index, i) = neighbor_distance;
      }
    }
    // Create graph for graph-based motion clustering.
    std::vector<int> first_node;
    std::vector<int> second_node;
    std::vector<float> weights;
    int number_edges = 0;
    for (unsigned int i = 0; i < number_corners; i++) {
      for (unsigned int j = i + 1; j < number_corners; j++) {
        if (chosen_distances.at<float>(i, j) > 0) {
          first_node.push_back(i);
          second_node.push_back(j);
          weights.push_back(chosen_distances.at<float>(i, j));
          number_edges++;
        }
      }
    }
    edge *edges = new edge[weights.size()];
    for (unsigned int i = 0; i < weights.size(); i++) {
      edges[i].a = first_node.at(i);
      edges[i].b = second_node.at(i);
      edges[i].w = weights.at(i);
    }
    // Segment.
    universe *u = segment_graph(number_corners, number_edges, edges, 0.5);
    // Draw.
    std::vector<cv::Scalar> colors(number_corners);
    for (unsigned int i = 0; i < number_corners; i++) {
      colors.at(i) = CV_RGB((uchar) random(), (uchar) random(),
                            (uchar) random());
    }
    // TODO: Check if the following lines are correct.
    std::stringstream stream_filename;
    std::string base_filename(argv[2]);
    stream_filename << base_filename << frame_number << std::string(".txt");
    std::string this_frame_filename = stream_filename.str();
    // Open output file.
    std::ofstream datos;
    datos.open(this_frame_filename.c_str());
    for (unsigned int i = 0; i < number_corners; i++) {
      datos << i << "\t" << previous_points.at(i) << "\t" << next_points.at(i)
            << "\t" << u->find(i) << std::endl;
    }
    datos.close();
    // Display Optical Flow result.
    cv::cvtColor(previous_frame, display_optical_flow_image, CV_GRAY2BGR);
    for (unsigned int i = 0; i < previous_corners.size(); i++) {
      cv::circle(display_optical_flow_image, previous_corners[i].pt, 4,
                  colors.at(u->find(i)));
      cv::line(display_optical_flow_image, previous_corners.at(i).pt,
               next_points.at(i),  colors.at(u->find(i)));
    }
    cv::imshow("optflow", display_optical_flow_image);
    cv::imshow("frame", current_frame);

    if (cv::waitKey(1000) >= 0)
			break;

  }
  return 0;
}
